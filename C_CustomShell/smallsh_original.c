/********************************************************************************
**Author: Shannon Jeffers
**Program: smallsh.c
**Class: CS 344 Operating Systems
**Description: A small version of a shell that handles cd, exit and status.
********************************************************************************/

#include<stdio.h>
#include<stdlib.h>
#include<sys/wait.h>
#include<string.h>
#include<sys/types.h>
#include<fcntl.h>
#include<unistd.h>
#include<signal.h>
#include<sys/stat.h>

#define MAX_CMDLEN 2048 //max chars a user can enter
#define MAX_FLEN 128 
#define MAX_ARGC 512 //max # arguments program will accept

//holds information for background processes
struct BgChild {
	int numCld;
	pid_t cldrn[MAX_ARGC];
};

//holds information for special commands/characters
struct MyFlags{
	int indirect;
	int background;
	int outdirect;
	int comments;
	int toExit;
};

struct BgChild bgChild;
struct MyFlags myFlags;

char cmdLine[MAX_CMDLEN]; //buffer for user input
char *args[MAX_ARGC]; //list of arugments
char inFile[MAX_FLEN]; //file to redirect input to
char outFile[MAX_FLEN]; //file to redirect output to
int numArgs;
int curStat;
int foregroundBool;

/*****************************************************************
**initstuff
**sets up the stuff that only needs to be set up once.
*****************************************************************/
void initstuff(){
	int i;
	for (i = 0; i < MAX_ARGC; i++){
		bgChild.cldrn[i] = -5;
	}
	bgChild.numCld = 0;
	foregroundBool = 0;
	curStat = 0;
}

/*****************************************************************
**setFlagsAndExp
**checks for certain characters and sets flags if found. expands $$
*****************************************************************/
void setFlagsAndExp(){
	char *found;
	pid_t theId;
	char mynum[25];
	myFlags.indirect = 0;
	myFlags.background = 0;
	myFlags.outdirect = 0;
	myFlags.comments = 0;
	myFlags.toExit = 0;

	memset(mynum, '\0', sizeof(mynum));

	//gets rid of the newline at the end
	if(cmdLine[strlen(cmdLine) -1] == '\n'){
		cmdLine[strlen(cmdLine) -1] = '\0';
	}

	//see if background process, set flag if yes
	if(cmdLine[strlen(cmdLine)-1] == '&'){
		myFlags.background = 1;
		cmdLine[strlen(cmdLine)-1] = '\0';
	}
	//checks to see if it contains a $$ and replaces with PID
	if(cmdLine[strlen(cmdLine)-1] == '$'){
		cmdLine[strlen(cmdLine)-1] = '\0'; 
		cmdLine[strlen(cmdLine)-1] = '\0';//since it is $$ needs to replace both
		theId = getpid();
		sprintf(mynum, "%d", theId);
		strcat(cmdLine, mynum);
	}
	// if there is an output director set flag
	if((found = strchr(cmdLine, '>')) != NULL)
		myFlags.outdirect = 1;

	// if there is an input director, set flag.
	if((found = strchr(cmdLine, '<')) != NULL)
		myFlags.indirect = 1;

	//if exit
	if(strcmp(cmdLine, "exit") == 0)
		myFlags.toExit = 1;

	//if it is a comment.
	if(cmdLine[0] == '#')
		myFlags.comments = 1;
	
}

/*****************************************************************
**foregroundChange
**changes into and outof foreground-only mode
*****************************************************************/
void foregroundChange(int sgnl){
	//if we arne't already in foreground-only mode, swap
	if(!foregroundBool){
		const char msg[] = "Entering foreground-only mode (& is now ignored)\n";
		write(STDOUT_FILENO, msg, sizeof(msg)-1);
		foregroundBool = 1;
	}
	//if we are already in foreground only mode, swap
	else{
		const char msg[] = "Exiting foreground-only mode.\n";
		write(STDOUT_FILENO, msg, sizeof(msg)-1);
		foregroundBool = 0;
	}
}

/*****************************************************************
**handleStatus
**used when status is called. Gives the status of the last foreground
**process that ended
*****************************************************************/
void handleStatus(){
	//if the child as exited..
	if(WIFEXITED(curStat)){
		printf("Exited: %d\n", WEXITSTATUS(curStat));
		fflush(stdout);
	}

	//if the child was signaled.
	if(WIFSIGNALED(curStat)){
		printf("Terminating Signal: %d\n", WSTOPSIG(curStat));
		fflush(stdout);
	}

}

/*****************************************************************
**process
**gets all arguemnts, handles cd, forks program
*****************************************************************/
void process(){
	numArgs = 0;
	char *found;
	int z;
	for(z = 0; z < MAX_ARGC; z++){
		args[z] = NULL;
	}

	//if the cd command was called
	if(strncmp("cd", cmdLine, 2) == 0){
		char workinDir[MAX_ARGC]; //storage for new directory
		int len;
		memset(workinDir, '\0', sizeof(workinDir));
		//gets the current working directory
		getcwd(workinDir, sizeof(workinDir));

		len = strlen(cmdLine);

		//if the user provided a directory to change to
		if(len > 2){
			//get that directory into the buffer
			args[numArgs] = strtok(cmdLine, " ");
			numArgs++;
			args[numArgs] = strtok(NULL, " ");
			//add the directory onto the current working directory
			strcat(workinDir, "/");
			strcat(workinDir, args[numArgs]);

			chdir(workinDir);
		}
		//if the user wants to go to the home directory
		else{
			char *home;
			home = getenv("HOME");
			chdir(home);
		}

	}
	//if the user entered status
	else if((found = strstr(cmdLine, "status")) != NULL){
		handleStatus();
	}
	//if the user entered an outside command, not one handled by the shell
	else{
		//get all the commands/args into the args array
		char *temp = strtok(cmdLine, " ");
		args[numArgs] = temp;
		numArgs++;
		pid_t spawn = -5;
		while(temp != NULL){
			temp = strtok(NULL, " ");
			args[numArgs] = temp;
			numArgs++;
		}

		//makes sure the last one is in the array.
		temp = strtok(NULL, "");
		if(temp != NULL){
			args[numArgs] = temp;
			numArgs++;
		}

		spawn = fork();

		//if the fork failed
		if(spawn < 0){
			printf("Fork Failure\n");
			exit(1);
		}
		//This is the child process!
		else if(spawn == 0){

			int input = STDIN_FILENO;
			int output = STDOUT_FILENO;
			//if there is a file to redirect input to
			if(myFlags.indirect){
				int i;
				memset(inFile, '\0', sizeof(inFile));
				for(i = 0; i < numArgs; i++){
					if(strcmp(args[i], "<") == 0){
						strcpy(inFile, args[i+1]);
						int v;
						//remove < from args
						for(v=i; v < numArgs; v++){
							args[v] = args[v+1]; 
						}
						numArgs--;
						//remove filename from args
						for(v=i; v < numArgs; v++){
							args[v] = args[v+1]; 
						}
						numArgs--;
						break;
					}
				}
				//open the file
				input = open(inFile, O_RDONLY);
				if(input < 0){
					printf("The file could not be opened.\n");
					exit(1);
				}
				//if the file opened, redirect into to it.
				else{
					dup2(input, 0);
					close(input);
				}
			}
			//if the user provided a file to redirect output
			if(myFlags.outdirect){
				int j;
				memset(outFile, '\0', sizeof(inFile));
				for(j = 0; j < numArgs; j++){
					if(strcmp(args[j], ">") == 0){
						strcpy(outFile, args[j+1]);
						int v;
						//remove > from args
						for(v=j; v < numArgs; v++){
							args[v] = args[v+1]; 
						}
						numArgs--;
						//remove filename from args
						for(v=j; v < numArgs; v++){
							args[v] = args[v+1]; 
						}
						numArgs--;
						break;
					}
				}
				//open the file
				output = open(outFile, O_WRONLY | O_CREAT | O_TRUNC, 0644);

				if(output < 0){
					printf("The file could not be opened or created.\n");
					exit(1);
				}
				//if the file opened, redirect output to it.
				else{
					dup2(output, 1);
					close(output);
				}
			}
			//if a file was not provided and its a background process
			/*if(!myFlags.indirect && myFlags.background){
				int fileDir = open("/dev/null", O_WRONLY);
				dup2(fileDir, 0);
			}
			//if a file was not provided and its a background process
			if(!myFlags.outdirect && myFlags.background){
				int fileDir = open("/dev/null", O_WRONLY);
				dup2(fileDir, 1);
			}*/
			//pass control to he command in args 0
			execvp(args[0], args);
			printf("Command not found.\n");
			exit(1);
		}
		//this is the parent
		else{
			//if it was a background command, and not in foreground only mode.
			if(myFlags.background && !foregroundBool){
				//add child pid to the array
				bgChild.cldrn[bgChild.numCld] = spawn;
				bgChild.numCld++;
				printf("Process %d has started in the background.\n", spawn);
			}
			else{
				//if not background, wait for pid before prompting user.
				waitpid(spawn, &curStat, 0);
			}
		}
	}
}

/*****************************************************************
**removecldrn
**remove a child from the background pid list
*****************************************************************/
void removecldrn(pid_t pid){
	int i;
	//find the location of the pid in the array
	for(i = 0; i < bgChild.numCld; i++){
		if(bgChild.cldrn[i] == pid){
			break;
		}
	}
	//shift the rest of the pids down one.
	for(i; i < bgChild.numCld; i++){
		bgChild.cldrn[i] = bgChild.cldrn[i+1];
		bgChild.numCld--;
	}

}

/*****************************************************************
**checkForEnd
**checks to see if any background pids end and displays message.
*****************************************************************/
void checkForEnd(){
	int thisStat;
	int i;
	//go through the entire array
	for(i = 0; i < bgChild.numCld; i++){
		//when a child returns...
		if(waitpid(bgChild.cldrn[i], &thisStat, WNOHANG) > 0){
			printf("Background Child %d done: ", bgChild.cldrn[i]);
			fflush(stdout);
			//if the child exited print the xit status
			if(WIFEXITED(thisStat)){
				printf("status %d\n", WEXITSTATUS(thisStat));
				fflush(stdout);
			}
			//if the child was signaled, print that status
			if(WIFSIGNALED(thisStat)){
				printf("status %d\n", WTERMSIG(thisStat));
				fflush(stdout);
			}
			removecldrn(bgChild.cldrn[i]);
			i--;
		}
	}
}

/*****************************************************************
**killForExit
**kills off remaining child processes so the shell can exit
*****************************************************************/
void killForExit(){
	int i;
	for(i = 0; i < bgChild.numCld; i++){
		kill(bgChild.cldrn[i], SIGINT);
	}
}

/*****************************************************************
**main
**runs shell on a loop
*****************************************************************/
void main(){
	int stop = 0;
	char* found;
	initstuff();

	//set up the signal handlers
	struct sigaction mySig = {0}, igSig = {0};
	mySig.sa_handler = foregroundChange;
	mySig.sa_flags = 0;
	sigaction(SIGTSTP, &mySig, NULL);

	igSig.sa_handler = SIG_IGN;
	sigaction(SIGINT, &igSig, NULL);

	//run until exit is entered.
	while(!stop){

		checkForEnd();

		fflush(stdout);

		printf(": ");

		memset(cmdLine, '\0', sizeof(cmdLine));
		//get users command line entrance
		fgets(cmdLine, sizeof(cmdLine), stdin);

		fflush(stdout);

		setFlagsAndExp();


		if(myFlags.toExit == 1){
			stop = 1;
		}
		else if(myFlags.comments == 1){
			continue;
		}
		else{
			process();
		}
	}

	killForExit();
}