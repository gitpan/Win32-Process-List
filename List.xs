#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <windows.h>
#include <tlhelp32.h>


void printError(char* msg, DWORD *err )
{
*err = GetLastError();
FormatMessage( FORMAT_MESSAGE_FROM_SYSTEM |
	FORMAT_MESSAGE_IGNORE_INSERTS,
	NULL,
        *err,
        0,
        msg,
        512,
        NULL );

}

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
ListProcesses(perror)
	SV* perror
	PREINIT:
		HANDLE hProcessSnap;
		PROCESSENTRY32 pe32;
		//DWORD dwPriorityClass;
    		DWORD err;
		HV * rh;
		char   wszMsgBuff[512];
    CODE:
        SetLastError(0);
    	//result = (AV *)sv_2mortal((SV *)newAV());
    	//rh = (HV *)sv_2mortal((SV *)newHV());
    	rh = newHV();
    	hProcessSnap = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
    	if( hProcessSnap == INVALID_HANDLE_VALUE )
	{
		printError(wszMsgBuff, &err );
		sv_upgrade(perror,SVt_PVIV);
		sv_setpvn(perror, (char*)wszMsgBuff, strlen(wszMsgBuff));
		sv_setiv(perror,(IV) err);
		SvPOK_on(perror);
		XPUSHs(sv_2mortal(newSViv(-1)));
	} else
	{
		pe32.dwSize = sizeof( PROCESSENTRY32 );
		if( !Process32First( hProcessSnap, &pe32 ) )
		{
			printError(wszMsgBuff,&err );
			sv_upgrade(perror,SVt_PVIV);
			sv_setpvn(perror, (char*)wszMsgBuff, strlen(wszMsgBuff));
			sv_setiv(perror,(IV) err);
			SvPOK_on(perror);
			XPUSHs(sv_2mortal(newSViv(-1)));
			CloseHandle( hProcessSnap );
		} else
		{
			  do
			  {
			  	if(hv_store(rh,pe32.szExeFile,strlen(pe32.szExeFile),newSVuv(pe32.th32ProcessID), 0)==NULL)
			  	{
			  		printf("can not store in rh\n");
			  		
			  	}
			  } while( Process32Next( hProcessSnap, &pe32 ) );
			CloseHandle( hProcessSnap );
		}
		

	}
	
    	RETVAL = newRV_noinc((SV *)rh);
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

