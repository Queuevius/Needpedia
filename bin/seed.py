import psycopg2
from os import system

conn = psycopg2.connect(
    host="db",
    database="needpedia_development",
    user="need_pedia",
    password="need_pedia"
)
conn.autocommit = True

cursor = conn.cursor()

cursor.execute('''SELECT COUNT(*) FROM "users"''')

result = cursor.fetchone()

cursor.close()
conn.close()

if result[0] == 0:
    system("rails db:seed")
