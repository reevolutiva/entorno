import os

def create_folder(domain, src, src_vol):
    src_path = os.path.join(src, domain)
    src_vol_path = os.path.join(src_vol, domain)

    os.makedirs(src_path, exist_ok=True)
    os.makedirs(src_vol_path, exist_ok=True)
