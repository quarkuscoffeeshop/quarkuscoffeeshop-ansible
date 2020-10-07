import pymongo
import os
connection_string=os.environ.get('MONGO_CONNECTION_STRING')


myclient = pymongo.MongoClient(connection_string)

mydb = myclient["cafedb"]