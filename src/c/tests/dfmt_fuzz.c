// Copyright 2021 Richard R. Masters
//
// The contents of this file may be used under the terms of the Apache License,
// Version 2.0.
//
//    (See accompanying file LICENSE-Apache or copy at
//     http://www.apache.org/licenses/LICENSE-2.0)
//
// Alternatively, the contents of this file may be used under the terms of
// the Boost Software License, Version 1.0.
//    (See accompanying file LICENSE-Boost or copy at
//     https://www.boost.org/LICENSE_1_0.txt)
//
// Unless required by applicable law or agreed to in writing, this software
// is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.

#include <unistd.h>
#include <inttypes.h>
#include <stdint.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

#include <string.h>
#include <time.h>
#include <math.h>

#include <signal.h>
#include <sys/wait.h>
#include <sys/prctl.h>

#include "doubleback/dparse.h"
#include "doubleback/dfmt.h"

void mypopen2(char *shell_command, char *arg0, pid_t *pid_p, int *read_from_fd, int *write_to_fd)
{
  pid_t pid = 0;
  int inpipefd[2];
  int outpipefd[2];

  pipe(inpipefd);
  pipe(outpipefd);
  pid = fork();
  if (pid == 0)
  {
    // child process

    // hook up to the pipe ends
    dup2(inpipefd[0], 0);
    dup2(outpipefd[1], 1);

    // close unused pipe ends
    close(inpipefd[1]);
    close(outpipefd[0]);

    // get SIGTERM when parent dies
    prctl(PR_SET_PDEATHSIG, SIGTERM);
    execl(shell_command, arg0, (char*) NULL);
    // if exec fails just exit child process
    exit(1);
  }

  // parent process

  // close unused pipe ends
  close(inpipefd[0]);
  close(outpipefd[1]);

  *pid_p = pid;
  *write_to_fd = inpipefd[1];
  *read_from_fd = outpipefd[0];
}

int main (int argc, char **argv) {
    char buffer[100];
    char alt_lang_buffer[100];
    char path[10240];
    char pass1[32];
    char pass2[32];
    char *alt_lang = NULL;
    pid_t pid;
    int read_from_fd, write_to_fd;
    int status;

    // If there is an argument, then it is the name of a language
    // stored in a sibling directory.
    // We launch it's echo process and later feed input to it and compare
    // against this c version.
    if (argc > 1) {
        alt_lang = argv[1];
        sprintf(path, "../../%s/dfmt-echo.sh", alt_lang);
        mypopen2(path, "dfmt-echo.sh", &pid, &read_from_fd, &write_to_fd);
    }

    double d, d2;
    while (__AFL_LOOP(100000)) {
        memset(buffer, 0, 100);
        read(0, buffer, 100);

        for (int i = 0; i < strlen(buffer); i++) {
           if (buffer[i] == '\n' || buffer[i] == '\r') {
               buffer[i] = 0;
           }
        }

        // for valid inputs do a round trip test 
        if (dparse(buffer, &d) == SUCCESS) {
            dfmt(d, pass1);
            dparse(pass1, &d2);
            if (!isnan(d) && d != d2) {
                abort();
            }
            dfmt(d2, pass2);
            if (strcmp(pass1, pass2)) {
                abort();
            }
            if (!alt_lang) {
                puts("VALID");
            }
        } else {
            if (!alt_lang) {
                puts("ERROR");
            }
        }

        if (alt_lang) {
           // write to the alternative implementation
           write(write_to_fd, buffer, strlen(buffer));
           write(write_to_fd, "\n", 1);

           // read back a line
           memset(alt_lang_buffer, 0, 100);
           int num_read, total_read = 0;
           do {
               num_read = read(read_from_fd, &alt_lang_buffer[total_read], 100 - total_read);
               total_read += num_read;
           } while (num_read && alt_lang_buffer[total_read - 1] != '\n');

           // verify c and alt implementation produce the same result
           if (dparse(buffer, &d) == SUCCESS) {
               dfmt(d, buffer);

               alt_lang_buffer[strlen(alt_lang_buffer)-1] = 0;
               if (strcmp(alt_lang_buffer, buffer)) {
                   abort();
               }
               puts("VALID");
           } else {
               if (strcmp(alt_lang_buffer, "ERROR\n")) {
                   abort();
               }
               puts("ERROR");
           }
       }
    }

    if (alt_lang) {
        kill(pid, SIGKILL); //send SIGKILL signal to the child process
        waitpid(pid, &status, 0);
    }
    return 0;
}

