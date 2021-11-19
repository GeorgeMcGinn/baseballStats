$If PIPECOM = UNDEFINED Then
    $Let PIPECOM = TRUE
    Function pipecom& (cmd As String, stdout As String, stderr As String)
        stdout = "": stderr = ""
        $If WIN Then
            Type SECURITY_ATTRIBUTES
                As _Unsigned Long nLength
                $If 64BIT Then
                    As String * 4 padding
                $End If
                As _Offset lpSecurityDescriptor
                As Long bInheritHandle
                $If 64BIT Then
                    As String * 4 padding2
                $End If
            End Type

            Type STARTUPINFO
                As Long cb
                $If 64BIT Then
                    As String * 4 padding
                $End If
                As _Offset lpReserved, lpDesktop, lpTitle
                As _Unsigned Long dwX, dwY, dwXSize, dwYSize, dwXCountChars, dwYCountChars, dwFillAttribute, dwFlags
                As _Unsigned Integer wShowWindow, cbReserved2
                $If 64BIT Then
                    As String * 4 padding2
                $End If
                As _Offset lpReserved2, hStdInput, hStdOutput, hStdError
            End Type

            Type PROCESS_INFORMATION
                As _Offset hProcess, hThread
                As _Unsigned Long dwProcessId
                $If 64BIT Then
                    As String * 4 padding
                $End If
            End Type

            Const STARTF_USESTDHANDLES = &H00000100
            Const CREATE_NO_WINDOW = &H8000000

            Const INFINITE = 4294967295
            Const WAIT_FAILED = &HFFFFFFFF

            Declare CustomType Library
                Function CreatePipe& (ByVal hReadPipe As _Offset, Byval hWritePipe As _Offset, Byval lpPipeAttributes As _Offset, Byval nSize As _Unsigned Long)
                Function CreateProcess& (ByVal lpApplicationName As _Offset, Byval lpCommandLine As _Offset, Byval lpProcessAttributes As _Offset, Byval lpThreadAttributes As _Offset, Byval bInheritHandles As Long, Byval dwCreationFlags As _Unsigned Long, Byval lpEnvironment As _Offset, Byval lpCurrentDirectory As _Offset, Byval lpStartupInfo As _Offset, Byval lpProcessInformation As _Offset)
                Function GetExitCodeProcess& (ByVal hProcess As _Offset, Byval lpExitCode As _Offset)
                Sub HandleClose Alias "CloseHandle" (ByVal hObject As _Offset)
                Function ReadFile& (ByVal hFile As _Offset, Byval lpBuffer As _Offset, Byval nNumberOfBytesToRead As _Unsigned Long, Byval lpNumberOfBytesRead As _Offset, Byval lpOverlapped As _Offset)
                Function WaitForSingleObject~& (ByVal hHandle As _Offset, Byval dwMilliseconds As _Unsigned Long)
            End Declare

            Dim As Long ok: ok = 1
            Dim As _Offset hStdOutPipeRead, hStdOutPipeWrite, hStdReadPipeError, hStdOutPipeError
            Dim As SECURITY_ATTRIBUTES sa: sa.nLength = Len(sa): sa.lpSecurityDescriptor = 0: sa.bInheritHandle = 1

            If CreatePipe(_Offset(hStdOutPipeRead), _Offset(hStdOutPipeWrite), _Offset(sa), 0) = 0 Then
                pipecom = -1
                Exit Function
            End If

            If CreatePipe(_Offset(hStdReadPipeError), _Offset(hStdOutPipeError), _Offset(sa), 0) = 0 Then
                pipecom = -1
                Exit Function
            End If

            Dim As STARTUPINFO si
            si.cb = Len(si)
            si.dwFlags = STARTF_USESTDHANDLES
            si.hStdError = hStdOutPipeError
            si.hStdOutput = hStdOutPipeWrite
            si.hStdInput = 0
            Dim As PROCESS_INFORMATION procinfo
            Dim As _Offset lpApplicationName
            Dim As String lpCommandLine: lpCommandLine = "cmd /c " + cmd + Chr$(0)
            Dim As _Offset lpProcessAttributes, lpThreadAttributes
            Dim As Long bInheritHandles: bInheritHandles = 1
            Dim As _Unsigned Long dwCreationFlags: dwCreationFlags = CREATE_NO_WINDOW
            Dim As _Offset lpEnvironment, lpCurrentDirectory
            ok = CreateProcess(lpApplicationName, _Offset(lpCommandLine), lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, _Offset(si), _Offset(procinfo))

            If ok = 0 Then
                pipecom = -1
                Exit Function
            End If

            HandleClose hStdOutPipeWrite
            HandleClose hStdOutPipeError

            Dim As String buf: buf = Space$(4096 + 1)
            Dim As _Unsigned Long dwRead
            While ReadFile(hStdOutPipeRead, _Offset(buf), 4096, _Offset(dwRead), 0) <> 0 And dwRead > 0
                buf = Mid$(buf, 1, dwRead)
                GoSub RemoveChr13
                stdout = stdout + buf
                buf = Space$(4096 + 1)
            Wend

            While ReadFile(hStdReadPipeError, _Offset(buf), 4096, _Offset(dwRead), 0) <> 0 And dwRead > 0
                buf = Mid$(buf, 1, dwRead)
                GoSub RemoveChr13
                stderr = stderr + buf
                buf = Space$(4096 + 1)
            Wend

            Dim As Long exit_code, ex_stat
            If WaitForSingleObject(procinfo.hProcess, INFINITE) <> WAIT_FAILED Then
                If GetExitCodeProcess(procinfo.hProcess, _Offset(exit_code)) Then
                    ex_stat = 1
                End If
            End If

            HandleClose hStdOutPipeRead
            HandleClose hStdReadPipeError
            If ex_stat = 1 Then
                pipecom = exit_code
            Else
                pipecom = -1
            End If

            Exit Function

            RemoveChr13:
            Dim As Long j
            j = InStr(buf, Chr$(13))
            Do While j
                buf = Left$(buf, j - 1) + Mid$(buf, j + 1)
                j = InStr(buf, Chr$(13))
            Loop
            Return
        $Else
            Declare CustomType Library
				Function popen%& (cmd As String, readtype As String)
				Function feof& (ByVal stream As _Offset)
				Function fgets$ (str As String, Byval n As Long, Byval stream As _Offset)
				Function pclose& (ByVal stream As _Offset)
            End Declare

            Declare Library
				Function WEXITSTATUS& (ByVal stat_val As Long)
            End Declare

            Dim As _Offset stream

            Dim buffer As String * 4096
            If _FileExists("pipestderr") Then
				Kill "pipestderr"
            End If
            stream = popen(cmd + " 2>pipestderr" + Chr$(0), "r")
            If stream Then
				While feof(stream) = 0
					If fgets(buffer, 4096, stream) <> "" And feof(stream) = 0 Then
						stdout = stdout + Mid$(buffer, 1, InStr(buffer, Chr$(0)) - 1)
					End If
				Wend
				Dim As Long status, exit_code
				status = pclose(stream)
				exit_code = WEXITSTATUS(status)
				If _FileExists("pipestderr") Then
					Dim As Integer errfile
					errfile = FreeFile
					Open "pipestderr" For Binary As #errfile
					If LOF(errfile) > 0 Then
						stderr = Space$(LOF(errfile))
						Get #errfile, , stderr
					End If
					Close #errfile
					Kill "pipestderr"
				End If
				pipecom = exit_code
			Else
				pipecom = -1
			End If
        $End If
    End Function

    Function pipecom_lite$ (cmd As String)
        Dim As Long a
        Dim As String stdout, stderr
        a = pipecom(cmd, stdout, stderr)
        If stderr <> "" Then
            pipecom_lite = stderr
        Else
            pipecom_lite = stdout
        End If
    End Function
$End If
