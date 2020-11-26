//
//  logger.h
//  
//
//  Created by Pavel Kasila on 11/26/20.
//

#ifndef logger_h
#define logger_h

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct {
    FILE* file;
} LoggerFile;

LoggerFile* logger_init(const char * __restrict filename);
void logger_write(const char * __restrict message, LoggerFile* lf);
void logger_deinit(LoggerFile* lf);

#endif /* logger_h */
