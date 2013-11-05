#include <stdio.h>
#include <stdlib.h>
#include <string.h>






int main(int argc, char *argv[])
{
        char *fn = argv[1];
        char *re = argv[2];
		char **file;
	    int i=1,j=0;
		file = (char **)malloc(sizeof(char*)*1024);
		char *myfile;
        myfile = (char *)malloc(sizeof(char)*1024*256);
		int count=0;
		char *str;
		char *result = (char *)malloc(sizeof(char)*1024*256);
		FILE *f;
	
	 if(re==NULL||fn==NULL){
        printf("input string or file");
        return -1;
			 }
    
	 f = fopen(fn, "r");

    file[0] = (char *)malloc(sizeof(char)*1024*256);

    while(i<1024){
        file[i] = file[i-1] + 256;
		fgets(file[i], 256, f);
		i++;
	}

    memcpy(myfile, &file[0][0], sizeof(char) * 1024*256);
   
    while(j<1024)
    {
        str = strstr(&myfile[j*256], re);
        if(str != NULL)
        {
            memcpy(&result[count*256], &myfile[j*256], sizeof(char)*256);
            count++;			
        }
		j++;
			

    }

	for (j=0;j < 1024;j++){
			if(&result[j*256]!=NULL)
            printf("%s", &result[j*256]);
			
    }
	return 0;
}
