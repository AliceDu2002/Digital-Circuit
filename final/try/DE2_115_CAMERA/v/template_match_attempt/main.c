#include <stdio.h>

int main(){
    int i = 63;
    for(;i>=0;i--){
        printf("pipeline_r[`IMG_ROW*%d+`TEMPL_SIZE-1:`IMG_ROW*%d]^templ_arr[`TEMPL_SIZE*(`TEMPL_SIZE-%d)-1:`TEMPL_SIZE*(`TEMPL_SIZE-%d)],\n", i, i, i, i+1);
    }
    return 0;
}