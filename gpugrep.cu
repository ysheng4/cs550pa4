#include <stdio.h>
#include <stdlib.h>
#include <string.h>


__device__ char *match(const char *s1, const char *s2){
    if(*s1==0)
  {
    if(*s2) return(char*)NULL;
    return (char*)s1;
  }
  while(*s1)
  {
    int i=0;
    while(1)
    {
      if(s2[i]==0) return (char *)s1;
      if(s2[i]!=s1[i]) break;
      i++;
    }
    s1++;
  }
  return (char*)NULL;
}


__global__ void grep(char *myfile, char *mystring, char *result, int line, int width){
    int j=0,count=0;
    char *str;
	 while(j<1024)
		   {
			 str = match(&myfile[j*256], mystring);
			 if(str != NULL)
			 {
				memcpy(&result[count*256], &myfile[j*256], sizeof(char)*256);
				count++;			
			 }
				j++;
		   }

}

int main(int argc, char* argv[])
{
	int i=1,j=0;
    char *fn = argv[1],*re = argv[2];
    char **file = (char **)malloc(sizeof(char*)*1024);
    char *result= (char *)malloc(sizeof(char)*1024*256);
	char *myfile, *mystring, *myresult;
    FILE *f;
    f = fopen(fn, "r");
    file[0] = (char *)malloc(sizeof(char)*1024*256);           
    if(re==NULL||fn==NULL)
	{
        printf("input string or file");
        return -1;
    }               
    while(i<1024)
	{
        file[i] = file[i-1] + 256;
        fgets(file[i], 256, f);
		i++;
	}
// Memory allocation   
    cudaMalloc((void**) &myfile, sizeof(char)*1024*256);
    cudaMalloc((void**) &mystring, strlen(re));
    cudaMalloc((void**) &myresult, sizeof(char)*1024*256);
// Copying memory to device
    cudaMemcpy(myfile, &file[0][0], sizeof(char)*1024*256, cudaMemcpyHostToDevice);
    cudaMemcpy(mystring, re,  strlen(re), cudaMemcpyHostToDevice);
// Calling the kernel
    grep<<<ceil((double)1024/256), 256>>>(myfile, mystring, myresult, 1024, 256);
// Copying results back to host
    cudaMemcpy(result, myresult, sizeof(char)*1024*256, cudaMemcpyDeviceToHost);
  	cudaFree(myfile);    
	cudaFree(mystring);
	cudaFree(myresult);  
    for(j = 0; j < 1024; j++)
    {
        if(&result[j*256] != NULL)
            printf("%s", &result[j*256]);
    }
    return 0;        
}
