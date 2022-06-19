# Tree program in Ada
### A small program for listing files and directories in a tree-structure

## Screenshot
![Screenshot of the program after running with -s flag](images/tree.png?raw=true "Screenshot of the program after running with -s flag")

## Author notes
I wrote this program during my first year at the University back in 2017. 

## Compiling
I compiled using GNATMAKE 7.5.0
```
$ gnatmake ./tree.adb
```

## Runtime
Default, list files from current directory
```
$ ./tree 
```
Help command
```
$ ./tree --help
```
Add filesize
```
$ ./tree -s
```
Add modified date
```
$ ./tree -m
```
Add full path
```
$ ./tree -f
```
The switches can be combined in any order
```
$ ./tree -smf
```
Specify a path
```
$ ./tree /home/username/Desktop -s
```

## Tested
The code have been tested on:
- Linux machine running Ubuntu 18.04.5 LTS with GNAT 7.5.0 
- Windows 10 machine running WSL (Windows Subsystem for Linux) and Ubuntu 18.04 LTS with GNAT 7.5.0

## Author
[Qulle](https://github.com/qulle/)