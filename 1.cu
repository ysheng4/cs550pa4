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

__device__ char *copy(char *dest, char *src, int n)
{
    char *tmp = dest;
        const char *s = src; 
        while (n--) *tmp++ = *s++ ; 
        return dest;
}


__global__ void grep(char *myFile, char *myregex, char *result, int line, int width){
    int i = blockDim.x * blockIdx.x + threadIdx.x;
    char *str;
    if(i < line)
    {
        str = match(&myFile[i*width], myregex);
        if(str != NULL)
            memcpy(&result[i*width], &myFile[i*width], sizeof(char)*width);
    }
}

int main(int argc, char* argv[])
{
        char *fn = argv[1];
    char *re = argv[2];
        char **file;
    char *result;
        FILE *f;
        f = fopen(fn, "r");
        file = (char **)malloc(sizeof(char*)*1024);
    result = (char *)malloc(sizeof(char)*1024*256);
    file[0] = (char *)malloc(sizeof(char)*1024*256);        
    int i,j=1;
    
    if(re==NULL||fn==NULL){
        printf("input:file name expression\n");
        return -1;
    }
   
        
    if(f == NULL)
    {
        printf("can not open file!\n");
        return -1;
    }

            
    while(j<1024)
	{
        file[j] = file[j-1] + 256;

        fgets(file[j], 256, f);
		j++;
	}

        // Memory allocation
    char *myfile, *myregex, *myresult;
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
    

    for(i = 0; i < 1024; i++)
    {
        if(&result[i*256] != NULL)
            printf("%s", &result[i*256]);
    }

    return 0;
        
}
