#!/bin/bash
mongo << EOF
use BookstoreDb
db.createCollection('Books')
db.Books.insertMany([{'Name':'Design Patterns','Price':54.93,'Category':'Computers','Author':'Ralph Johnson'}, {'Name':'Clean Code','Price':43.15,'Category':'Computers','Author':'Robert C. Martin'}])
EOF
