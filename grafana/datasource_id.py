import json
import pathlib
import argparse

parser = argparse.ArgumentParser(description='Writes ID of the created datasource to stdout.')
parser.add_argument('--gf_dsh', type=pathlib.Path, required=True, help='The datasource description of the created dashboard.')

args = parser.parse_args()
with open(args.gf_dsh) as gf_dsh_file:
    gf_dsh = json.load(gf_dsh_file)['datasource']
    print(gf_dsh['id'])
