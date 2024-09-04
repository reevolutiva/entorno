import google.auth
from google.oauth2 import service_account
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from googleapiclient.http import MediaFileUpload

SCOPES = ['https://www.googleapis.com/auth/drive']
SERVICE_ACCOUNT_FILE = 'service_acount.json'
PARENT_FOLDER_ID = '1VuvE7JhZ7s7BZ2B-IdzIyOB-6VC6nWVh'

def authenticate():
  creds = service_account.Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
  return creds

# Esta función sube un archivo a Google Drive
def upload_file( file_path, filename, folder_id ):
  
  creds = authenticate(  )
  service = build('drive', 'v3', credentials=creds)
  
  file_metadata = {
    'name': filename ,
    'parents': [folder_id]
  }
  
  try:
    
    file = service.files().create(
      body=file_metadata, 
      media_body=file_path
    ).execute()
    
    file_id = file.get('id')
    name = file.get('name')
    msg = f"File {name} uploaded successfully"
  
    return { 'file_id': file_id, 'name': name, 'msg': msg }
  
  except HttpError as e:
    return f"Error uploading {filename}: {e}"
  

  # Esta función elimina un archivo de Google Drive
def delete_file(file_id):
  creds = authenticate()
  service = build('drive', 'v3', credentials=creds)
    
  try:
    service.files().delete(fileId=file_id).execute()
    return "File deleted successfully"
  except HttpError as e:
    return f"Error deleting file: {e}"
  

#salida = upload_file( './union_sagrada.pdf', 'Union Sagrada.pdf', PARENT_FOLDER_ID )
#print( salida )

salida = delete_file( '1KTYnsWQY53qDh7jBks5coIriEOT') # ID del archivo a eliminar
print( salida )