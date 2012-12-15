//
//  bark.c
//  Bubble Beat
//
//  Created by Scott McCoid on 12/15/12.
//
//

#include "bark.h"

#pragma mark - Bark Memory Management - 

BARK* newBark(int windowSize, int sampleRate)
{
    BARK* bark = (BARK *)malloc(sizeof(BARK));
    if (bark == NULL)
        return NULL;
    
    assert(POWER_OF_TWO(windowSize));
    bark->windowSize = windowSize;
    bark->sampleRate = sampleRate;
    
    newBarkBands(bark);
    
    return bark;
}

void freeBark(BARK* bark)
{
    freeBarkBands(bark);
    free(bark);
}

#pragma mark - Bark Band Memory Management -

void newBarkBands(BARK* bark)
{
    for (int i = 0; i < NUM_BARK_FILTER_BUFS; i++)
    {
        bark->filterBands[i].band = (float *)malloc((bark->windowSize / 2) * sizeof(float));
        
        for (int j = 0; j < bark->windowSize / 2; j++)
            bark->filterBands[i].band[j] = 0.0;
    }
    
}

void freeBarkBands(BARK* bark)
{
    for (int i = 0; i < NUM_BARK_FILTER_BUFS; i++)
        free(bark->filterBands[i].band);
}

#pragma mark - Filterbank Functions - 

void createFilterbank(BARK* bark)
{
    float period = bark->sampleRate / bark->windowSize;
    int direction = 0;                     // direction is either +1 for increasing or -1 for decreasing
    
    float length, slope, point;
    
    // NUM_BARKS is still 24, but we have an array of length 26, so we've added lower and upper limits
    for (int i = 0; i < NUM_BARKS; i++)
    {
        for (int j = 0; j < bark->windowSize / 2; j++)
        {
            float frequency = period * j;
            
            if (frequency >= barkCenterFreq[i] && frequency < barkCenterFreq[i + 1])
            {
                direction = 1;
                length = barkCenterFreq[i + 1] - barkCenterFreq[i];
            }
            else if (frequency >= barkCenterFreq[i + 1] && frequency < barkCenterFreq[i + 2])
            {
                direction = -1;
                length = barkCenterFreq[i + 2] - barkCenterFreq[i + 1];
            }
            else
                direction = 0;  // this means we're over the bounds and don't want to deal with it
            
            if (direction != 0)
            {
                slope = direction / length;
                point = 1 - slope * barkCenterFreq[i + 1];
                
                bark->filterBands[i % 2].band[j] = slope * frequency + point;         // y = mx + b
            }
        }
    }
}

// TODO: fix this function, the analysis buffer will be in COMPLEX_SPLIT form
void multiplyBarkFilterbank(BARK* bark, float* analysis)
{
    for (int i = 0; i < bark->windowSize / 2; i++)
    {
        bark->filteredOdd[i] = bark->filterBands[0].band[i] * analysis[i];           // non overlapping bands starting at 0
        bark->filteredEven[i] = bark->filterBands[1].band[i] * analysis[i];          // non overlapping bands starting at 50 (first bark center)
        analysis[i] = bark->filteredOdd[i] + bark->filteredEven[i];
    }
}