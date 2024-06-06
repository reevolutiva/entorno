import os

def list_directories(path):
    return [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]

if __name__ == '__main__':
    import sys
    if len(sys.argv) != 2:
        print("Usage: python file_mannager.py <path>")
    else:
        print(list_directories(sys.argv[1]))
