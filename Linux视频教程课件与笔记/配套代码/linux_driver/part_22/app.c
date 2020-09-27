#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#include <string.h>
#include <poll.h>
int main(int argc, char *argv[])
{
   struct pollfd fds ={0};
   fds.fd =0;
   fds.events=POLLIN;

   int ret = poll(&fds,1,5000);

   if(ret == -1)
        printf("poll error!\r\n");
    else if(ret)
        printf("data is ready!\r\n");
    else if(ret ==0)
        printf("time out!/r/n");
}