// mex_sigint_handler.cpp
//adapted from http://newsgroups.derkeiler.com/Archive/Comp/comp.soft-sys.matlab/2006-06/msg01594.html
//timothee cour
//caution: SIGHANDLE defines mexAtExit
//TODO:make sure it works both for console matlab and application matlab
// Timothee Cour, 30-Sep-2010 01:54:13 -- DO NOT DISTRIBUTE



#pragma once

//#if defined(UNIX) || defined(MACINTOSH)

#include "signal.h"
#include <setjmp.h>

// #define SIG_HANDLED SIGINT
#define SIG_HANDLED SIGQUIT //CTRL+\

static void signalHandler(int);

/* Global variables - so that handler can see them */
static struct sigaction sigaction_var_new, sigaction_var_old;
static jmp_buf jmp_env_sigaction;

void sigaction_restore_function(){
    sigaction(SIG_HANDLED, &sigaction_var_old, &sigaction_var_new);
    //     sigaction(SIGQUIT, &sigaction_var_old, &sigaction_var_new);
}

/* Signal handler */
static void signalHandler(int sig)
{
    printf("Trapped %d\n", sig);
    printf("Resetting signal handler for SIG_HANDLED\n");
    sigaction_restore_function();
    longjmp(jmp_env_sigaction, 1);
}

#define SIGHANDLE \
sigaction_var_new.sa_handler=signalHandler;\
sigaction(SIG_HANDLED, &sigaction_var_new, &sigaction_var_old);\
if(setjmp(jmp_env_sigaction)) {\
mexErrMsgTxt("Ctrl-C pressed.");\
return;\
}\
mexAtExit(sigaction_restore_function);

//#else
//#define SIGHANDLE ;
//#endif
