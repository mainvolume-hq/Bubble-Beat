//
//  peak_picker.c
//  Bubble Beat
//
//  author: jay
//  [sonic apps union]
//

#include "peak_picker.h"
#include "util.h"
#include <math.h>
#include "stdio.h"

PEAK_PICKER* newPeakPicker()
{
    PEAK_PICKER* peakPicker = (PEAK_PICKER *)malloc(sizeof(PEAK_PICKER));
    if (peakPicker == NULL)
        return NULL;
    
    peakPicker-> flag =                 0;
    peakPicker-> debounce_iterator =    0;
    peakPicker-> debounce_threshold =   0;
    peakPicker-> u_threshold =          0.5;
    peakPicker-> l_threshold =          0.1;
    peakPicker-> u_threshold_scale =    10.0;
    peakPicker-> l_threshold_scale =    1.0;
    peakPicker-> cof_threshold =        10;
    peakPicker-> cof_iterator =         0;
    peakPicker-> cof_flag =             0;
    peakPicker-> maskingDecay =         0.7;
    peakPicker-> masking_threshold =    4;
    peakPicker-> mask_iterator =        0;
    peakPicker-> mask_flag =            0;
    
    
    return peakPicker;
}

void freePP(PEAK_PICKER* pp)
{
    free(pp);
}

void accumulate_bin_differences(PEAK_PICKER* pp, BARK* bark){
    
    float diff = 0;
    int length = sizeof(bark->barkBins) / sizeof(float);
    for (int i=0; i<length; i++) {
        diff += halfwaveRectify(fabsf(bark->barkBins[i]) - fabsf(bark->prevBarkBins[i]));
    }
    
    pp->bark_difference = diff;
    
    //printf("diff: %f \n",diff);
    
}

void applyMask(PEAK_PICKER* pp){
    
    // check if flag is raised
    if (pp->mask_flag == 1) {
        
        //if so, but we've reached the masking threshold, lower flag
        if (pp->mask_iterator == pp->masking_threshold) {
            pp->mask_flag = 0;
            pp->mask_iterator = 0;
        }
        else{
            //otherwise, we'll multiply our feature by the decay a buncha times.
            //(this allows for a lot of decay initially and then not so much later)
            for (int i = 0; i < pp-> masking_threshold - pp-> mask_iterator; i++) {
                pp->bark_difference = pp->bark_difference * pp->maskingDecay;
            }
        }
        //iterate
        pp->mask_iterator++;
    }

}


void filterConsecutiveOnsets(PEAK_PICKER* pp){
    
    //check if flag is rasied
    if (pp->cof_flag == 1) {
        
        //if we've passed the threshold, lower it.
        if (pp->cof_iterator > pp-> cof_threshold) {
            pp-> cof_flag = 0;
            pp-> cof_iterator = 0;
        }
        
    //iterate
    else pp->cof_iterator++;
    }
}

void pickPeaks(PEAK_PICKER* pp){

    switch (pp->flag) {
        case 0:
            //flag is down
            
            //if we're above the upper threshold...
            if (pp->bark_difference > pp->u_threshold) {
                
                //and we're not filtering consecutive onsets,
                if (pp->cof_flag == 0) {
                    
                    //Let's flag this spot for a potential onset and hang on to that peak value if it ends up being one.
                    pp->flag = 1;
                    pp->debounce_iterator = 1;
                    pp->peak_value = pp->bark_difference;
                    
                }
            }
            
            //otherwise, we'll keep waiting for an onset
            
            break;
            
        case 1:
            //flag is up
            
            
            //did we go higher above the threshold?
            if (pp->bark_difference > pp->peak_value) {
                
                if (pp->cof_flag == 0) {
                    
                    //flag this as a better estimate for the onset
                    
                    pp->flag = 1;
                    pp->debounce_iterator = 1;
                    pp->peak_value = pp->bark_difference;
                    
                }
            }
            
            //if not...
            else{
                
                //Have we gone beyond our debouncing window?
                if (pp->debounce_iterator > pp->debounce_threshold) {
                    
                    if (pp->cof_flag ==0) {
                        
                        //onset verified!
                        
                        // TODO: communicate with view controller
                        printf("ONSET!");
                        
                        pp->debounce_iterator = 0;
                        pp->flag = 0;
                        pp->cof_flag = 1;
                        pp->mask_flag = 1;
                        
                    }
                }
                
                else{
                    
                    //are we below our lower threshold?
                    if(pp->bark_difference < pp->l_threshold) {
                        
                        if (pp->cof_flag == 0) {
                            
                            //onset verified!
                            
                            //TODO: communicate with view controller
                            printf("ONSET!");
                            
                            pp->debounce_iterator=0;
                            pp->flag = 0;
                            pp->cof_flag = 1;
                            pp->mask_flag = 1;
                        }
                    }
                    
                    //we have a peak flagged, but we haven't increased or crossed the lower threshold yet.
                    //Lets wait a bit longer to make sure our tagged peak is an onset
                    
                    else pp->debounce_iterator++;
                    
                }
                
            }
            break;
    }
}










