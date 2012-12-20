//
//  bark.h
//  DSPLib
//
//  author: scott
//	[sonic apps union]
//
//	description: This file defines all the functions and values associated
//  with the bark frequency bounds and filter banks
//
//
#ifndef DSPLIB_BARK
#define DSPLIB_BARK

#include <stdlib.h>
#include <assert.h>
#include "constants.h"
#include "util.h"

#define NUM_BARKS 24
#define NUM_BARK_FILTER_BUFS 2

int barkCenterFreq[26] = {0, 50, 150, 250, 350, 450, 570, 700, 840, 1000, 1170, 1370, 1600, 1850, 2150, 2500, 2900, 3400, 4000, 4800, 5800, 7000, 8500, 10500, 13500, 15500};

float bandWeightings[24] = { 0.7762, 0.6854, 0.6647, 0.6373, 0.6255, 0.6170, 0.6139, 0.6107, 0.6127, 0.6329, 0.6380, 0.6430, 0.6151, 0.6033, 0.5914, 0.5843, 0.5895, 0.5947, 0.6237, 0.6703, 0.6920, 0.7137, 0.7217, 0.7217 };


typedef struct t_bark_bin
{
    float*  band;
} BARK_BIN;


typedef struct t_bark
{
    BARK_BIN  filterBands[2];
    float*    filteredOdd;
    float*    filteredEven;
    
    int       windowSize;
    int       sampleRate;
} BARK;


BARK* newBark(int windowSize, int sampleRate);
void freeBark(BARK* bark);

void newBarkBands(BARK* bark);
void freeBarkBands(BARK* bark);

void createBarkFilterbank(BARK* bark);
void multiplyBarkFilterbank(BARK* bark, float* analysis);

#endif
