#!/bin/python
import sys, json, subprocess

S = json.loads(subprocess.run("swaymsg -t get_outputs --raw".split(), stdout=subprocess.PIPE).stdout)[0]

name = S['name']
modes = S['modes']
cur = S['current_mode']

modes = [x for x in modes if x['width']==cur['width'] and x['height']==cur['height']]
refresh_max = max([x['refresh'] for x in modes])
mode = [x for x in modes if x['refresh']==refresh_max][0]

width = mode['width']
height = mode['height']
refresh = float(mode['refresh'])/1000.0

print(f'output {name} mode {width}x{height}@{refresh:.3f}Hz')
