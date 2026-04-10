Set WshShell = CreateObject("WScript.Shell")
WshShell.CurrentDirectory = "D:\排期系统-河源版"
WshShell.Run "C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe app.py", 0, False
