#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <windows.h>
#include "psapi.h"

static int
not_here(char *s)
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant(char *name, int len, int arg)
{
    errno = EINVAL;
    return 0;
}

MODULE = Win32::Process::List		PACKAGE = Win32::Process::List		

SV * 
ListProcesses(needed,perror)
	SV* needed
	SV* perror
	PREINIT:
		AV * result;
		DWORD aProcesses[1024]; 
		DWORD cbNeeded;
		DWORD cProcesses;
		unsigned int i;
    		char szProcessName[MAX_PATH] = "unknown";
    		DWORD err;
    		HMODULE hMod;
		char tmp[1024] = { 0 };
		char tmp1[1024] = { 0 };
		HV * rh;
		//LPTSTR   wszMsgBuff[512];  // Buffer for text.
		char   wszMsgBuff[512];
		DWORD   dwChars;  // Number of chars returned.

    CODE:
        SetLastError(0);
    	result = (AV *)sv_2mortal((SV *)newAV());
    	rh = (HV *)sv_2mortal((SV *)newHV());
	if(!EnumProcesses(aProcesses,sizeof(aProcesses),&cbNeeded))
	{
		err = GetLastError();
		//printf("Error in EnumProcesses\n");
		dwChars = FormatMessage( FORMAT_MESSAGE_FROM_SYSTEM |
               				FORMAT_MESSAGE_IGNORE_INSERTS,
					NULL,
                             		err,
                             		0,
                             		(LPTSTR)wszMsgBuff,
                             		512,
                             		NULL );
                sv_upgrade(perror,SVt_PVIV);
		sv_setpvn(perror, (char*)wszMsgBuff, strlen(wszMsgBuff));
		sv_setiv(perror,(IV) err);
		SvPOK_on(perror);
		XPUSHs(sv_2mortal(newSViv(-1)));
	}
	
	cProcesses = cbNeeded / sizeof(DWORD);
	//printf("Number of processes: %d\n",cProcesses);
	for ( i = 0; i < cProcesses; i++ ) {
	     HANDLE hProcess = OpenProcess( PROCESS_QUERY_INFORMATION|PROCESS_VM_READ,TRUE, aProcesses[i] );
	     if(hProcess != NULL)
	     {
		cbNeeded=0;
	     	if ( EnumProcessModules( hProcess, &hMod, sizeof(hMod), &cbNeeded) > 0 )
		{
        	    GetModuleBaseName( hProcess, hMod, szProcessName, sizeof(szProcessName) );
        	    //printf("Storing: %s (%i) \n",szProcessName,aProcesses[i]);
        	    hv_store(rh,szProcessName,strlen(szProcessName),newSVnv(aProcesses[i]), 0);
        	} else {
        		//printf("Error in EnumProcessModules\n");
        		if(strcmp(szProcessName, "unknown")) {
				err = GetLastError();
				

				dwChars = FormatMessage( FORMAT_MESSAGE_FROM_SYSTEM |
                             				FORMAT_MESSAGE_IGNORE_INSERTS,
                             				NULL,
                             				err,
                             				0,
                             				(LPTSTR)wszMsgBuff,
                             				512,
                             				NULL );

				sprintf(tmp, "EnumProcessModules: An error occured %s Process: (%s) PID: %i\n", wszMsgBuff,szProcessName, aProcesses[i]);
		                sv_upgrade(perror,SVt_PVIV);
				sv_setpvn(perror, tmp, strlen(tmp));
				//sv_setiv(perror,(IV) err);
				SvPOK_on(perror);
				XPUSHs(sv_2mortal(newSViv(-1)));
			}
		}

	     } else {
	     		//printf("Process with PID %i could not opened\n", aProcesses[i]);
			dwChars = FormatMessage( FORMAT_MESSAGE_FROM_SYSTEM,
                             			NULL,
                             			GetLastError(),
                             			0,
                             			(LPTSTR)wszMsgBuff,
                             			512,
                             			NULL );
			sprintf(tmp, "PID %i: %s", aProcesses[i], wszMsgBuff);
			strcat(tmp1, tmp);
			sv_upgrade(perror,SVt_PVIV);
			sv_setpvn(perror, tmp1, strlen(tmp1));
			//sv_setiv(perror,(IV) err);
			SvPOK_on(perror);
			XPUSHs(sv_2mortal(newSViv(-1)));
	    }
    	}
    	av_push(result, newRV((SV *)rh));
    	RETVAL = newRV((SV *)result);
	OUTPUT:
		RETVAL
		perror
	

double
constant(sv,arg)
    PREINIT:
	STRLEN		len;
    INPUT:
	SV *		sv
	char *		s = SvPV(sv, len);
	int		arg
    CODE:
	RETVAL = constant(s,len,arg);
    OUTPUT:
	RETVAL

