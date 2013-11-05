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


__global__ void grep(char *myfile, char *myregex, char *result, int line, int width){
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    char *str;
    if(i < line)
    {
        str = match(&myfile[i*width], myregex);
        if(str != NULL)
            memcpy(&result[i*width], &myfile[i*width], sizeof(char)*width);
    }
}

int main(int argc, char* argv[])
{
	int i,j=1;
    char *fn = argv[1],*re = argv[2];
    char **file = (char **)malloc(sizeof(char*)*1024);
    char *result= (char *)malloc(sizeof(char)*1024*256);
	char *myfile, *myregex, *myresult;
    FILE *f;
    f = fopen(fn, "r");
    file[0] = (char *)malloc(sizeof(char)*1024*256);        
    
    

    if(re==NULL||fn==NULL){
        printf("input string or file");
        return -1;
    }
   
            
    while(j<1024)
	{
        file[j] = file[j-1] + 256;

        fgets(file[j], 256, f);
		j++;
	}

        // Memory allocation
    
    cudaMalloc((void**) &myfile, sizeof(char)*1024*256);
    cudaMalloc((void**) &myregex, strlen(re));
    cudaMalloc((void**) &myresult, sizeof(char)*1024*256);
        // Copying memory to device
    cudaMemcpy(myfile, &file[0][0], sizeof(char)*1024*256, cudaMemcpyHostToDevice);
    cudaMemcpy(myregex, re,  strlen(re), cudaMemcpyHostToDevice);
        // Calling the kernel
    grep<<<ceil((double)1024/256), 256>>>(myfile, myregex, myresult, 1024, 256);
        // Copying results back to host
    cudaMemcpy(result, myresult, sizeof(char)*1024*256, cudaMemcpyDeviceToHost);
  	cudaFree(myfile);    
	cudaFree(myregex);
	cudaFree(myresult);  

    for(i = 0; i < 1024; i++)
    {
        if(&result[i*256] != NULL)
            printf("%s", &result[i*256]);
    }


    return 0;
	
        
}
