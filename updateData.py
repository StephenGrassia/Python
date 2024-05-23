## Virginia Beach Police Incident Report Data
## Author: Stephen Grassia
## Created On: 4/2/2024
## Purpose: Fetch data from City of Virginia Beach ArcGIS Portal, grab new rows, then append PostgreSQL database

import os 
import pandas as pd 
import arcpy
from sqlalchemy import create_engine

arcpy.env.overwriteOutput = True

# Fetch Data
ws = "C:/Path/To/Main/Workspace"
gdb = "C:/Path/To/Main/.gdb"
outCSV = "C:/Path/To/.csv"

url = "https://services2.arcgis.com/CyVvlIiUfRBmMQuu/arcgis/rest/services/Police_Incident_Reports_view/FeatureServer/0/"
crimeTable = "C:Path/.gdb/crimeTable"

def dataConversion():
    print("Collecting data")
    arcpy.conversion.ExportTable(url, crimeTable)
    cols = [f.name for f in arcpy.ListFields(crimeTable) if f.type != "Geometry"]
    data = pd.DataFrame(data=arcpy.da.SearchCursor(crimeTable, cols), columns = cols)
    print(f"Data retrieved")
    data = data.drop(columns=['OBJECTID'], axis=1)
    return data

data = dataConversion()

data.to_csv(outCSV)

conn = create_engine('postgresql+psycopg2://username:password@localhost:5432/postgres')

query = '''SELECT IncidentNumber 
           FROM police_incidents'''
db_incidents = pd.read_sql(query, conn)['incidentnumber'].tolist()
data.reset_index(inplace=True)
data['IncidentNumber'] = data['IncidentNumber'].astype(str)
newData = [incnum for incnum in data['IncidentNumber'] if incnum not in db_incidents]

newRows = data[data['IncidentNumber'].isin(newData)]
newRows.columns = map(str.lower, newRows.columns)
newRows.set_index('incidentnumber', inplace=True)
newRows.drop(['index'],axis=1, inplace=True)
newRows = newRows.rename(columns={'precinct': 'precincts'})
newRows.to_sql('police_incidents', conn, if_exists='append')
