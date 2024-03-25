#import argparse
#parser = argparse.ArgumentParser()
#parser.add_argument('
import sys

bad_to_good_sample_names = {'JN-DSRCT1.shEWSWT1': 'JN-DSRCT1-shEWSWT1',
                            'JN-DSRCT1.shGFP': 'JN-DSRCT1-shGFP',
                            'L3.6pl': 'L3-6pl',
                            'Cardiomyocyte-E12.5':'Cardiomyocyte-E12-5',
                            'Cardiomyocyte-E18.5': 'Cardiomyocyte-E18-5'}    

def correct_bad_sample_name(name):
    if name in bad_to_good_sample_names:
        return(bad_to_good_sample_names[name])
    else:
        return(name)

name = sys.stdin.read().strip()
correct_name = correct_bad_sample_name(name)
print(correct_name)
