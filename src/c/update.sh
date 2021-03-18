bazel build -c opt --jobs=1 //scripts:shortest-native-c-double.pdf
bazel build -c opt --jobs=1 //scripts:shortest-native-c-double-time.pdf 
bazel build -c opt --jobs=1 //scripts:shortest-native-c-double-time.png 
bazel build -c opt --jobs=1 //scripts:shortest-native-c-double-length.pdf
bazel build -c opt --jobs=1 //scripts:shortest-native-c-double-length.png
ssh -i ~/.ssh/rickaws-tfci.pem ubuntu@34.215.73.90 rm -f "*.pdf" "*.png"
scp -i ~/.ssh/rickaws-tfci.pem bazel-bin/scripts/*.{pdf,png} ubuntu@34.215.73.90:
