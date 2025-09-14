if ! command -v python3 &> /dev/null; then
    exit 1
fi
cd "$(dirname "$0")"
if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
if [ ! -f "__init__.py" ]; then
   
    exit 1
fi
python3 -c "from __init__ import create_app; create_app().run(debug=True)"