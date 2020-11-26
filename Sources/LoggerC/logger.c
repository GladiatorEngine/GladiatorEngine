//
//  logger.c
//  
//
//  Created by Pavel Kasila on 11/26/20.
//

#include "logger.h"

LoggerFile* logger_init(const char * __restrict filename) {
    printf("Opening log file in %s\n", filename);
    FILE* f = fopen(filename, "wb");
    LoggerFile* p = malloc(sizeof(LoggerFile));
    
    p->file = f;
    
    fseek(f, 0L, SEEK_END); // Go to EOF
    
    return p;
}

void logger_write(const char * __restrict message, LoggerFile* lf) {
    size_t length = strlen(message);
    char* fMsg = malloc(length+1);
    strcpy(fMsg, message);
    strcat(fMsg, "\n");
    fputs(fMsg, lf->file);
}

void logger_deinit(LoggerFile* lf) {
    fclose(lf->file);
}
