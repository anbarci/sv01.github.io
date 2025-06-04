#!/bin/bash
# ottoman_setup.sh - Tek komutla tam kurulum

set -e
LOG_FILE="/tmp/ottoman_setup.log"

# Renk kodları
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log fonksiyonu
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a $LOG_FILE
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a $LOG_FILE
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a $LOG_FILE
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a $LOG_FILE
}

# Banner
cat << 'EOF'
╔══════════════════════════════════════════════════════════════════╗
║                    OTTOMAN MINER + YOLOv4                       ║
║                   Otomatik Kurulum Script'i                     ║
║                                                                  ║
║  🏛️  Osmanlı Belge İşleme Sistemi                              ║
║  🤖  AI Tabanlı Karakter Tanıma                                ║
║  📊  %98.71 Doğruluk Oranı                                     ║
╚══════════════════════════════════════════════════════════════════╝
EOF

log "🚀 Ottoman Miner kurulumu başlıyor..."

# Sistem kontrolü
info "🔍 Sistem kontrolü yapılıyor..."
OS_VERSION=$(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")
MEMORY_GB=$(free -g | awk '/^Mem:/{print $2}')
DISK_GB=$(df -BG / | awk 'NR==2{print $4}' | sed 's/G//')

log "📋 Sistem Bilgileri:"
log "   OS: $OS_VERSION"
log "   RAM: ${MEMORY_GB}GB"
log "   Disk: ${DISK_GB}GB"

# Minimum gereksinim kontrolü
if [ "$MEMORY_GB" -lt 4 ]; then
    warning "RAM 4GB'dan az! Performans sorunları yaşayabilirsiniz."
fi

if [ "$DISK_GB" -lt 20 ]; then
    error "En az 20GB boş disk alanı gerekli!"
fi

# 1. Sistem güncelleme
log "📦 Sistem paketleri güncelleniyor..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update && sudo apt upgrade -y >> $LOG_FILE 2>&1

# 2. Temel paketler
log "🔧 Temel geliştirme araçları kuruluyor..."
sudo apt install -y \
    python3 \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    wget \
    curl \
    unzip \
    zip \
    build-essential \
    cmake \
    pkg-config \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release >> $LOG_FILE 2>&1

# 3. OpenCV ve görüntü işleme
log "🖼️  OpenCV ve görüntü işleme kütüphaneleri kuruluyor..."
sudo apt install -y \
    libopencv-dev \
    python3-opencv \
    libgtk-3-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libatlas-base-dev \
    gfortran \
    libjpeg8-dev \
    liblapack-dev \
    libhdf5-dev >> $LOG_FILE 2>&1

# 4. PDF ve OCR araçları
log "📄 PDF ve OCR araçları kuruluyor..."
sudo apt install -y \
    poppler-utils \
    tesseract-ocr \
    tesseract-ocr-tur \
    tesseract-ocr-ara \
    tesseract-ocr-eng \
    imagemagick \
    ghostscript >> $LOG_FILE 2>&1

# 5. Fontlar ve dil desteği
log "🔤 Font ve dil desteği ekleniyor..."
sudo apt install -y \
    language-pack-tr \
    fonts-liberation \
    fonts-dejavu-core \
    fonts-noto \
    fonts-noto-cjk \
    ttf-mscorefonts-installer >> $LOG_FILE 2>&1

# 6. Ana proje dizini
PROJECT_DIR="$HOME/ottoman-project"
log "📁 Proje dizini oluşturuluyor: $PROJECT_DIR"

if [ -d "$PROJECT_DIR" ]; then
    warning "Proje dizini zaten mevcut. Yedekleniyor..."
    mv "$PROJECT_DIR" "${PROJECT_DIR}_backup_$(date +%Y%m%d_%H%M%S)"
fi

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 7. Python virtual environment
log "🐍 Python sanal ortamı oluşturuluyor..."
python3 -m venv ottoman_env

# Virtual environment aktivasyonu
source ottoman_env/bin/activate

# Pip güncelleme
pip install --upgrade pip setuptools wheel >> $LOG_FILE 2>&1

# 8. Requirements dosyası oluşturma
log "📚 Python bağımlılıkları tanımlanıyor..."
cat > requirements.txt << 'EOF'
# Core AI/ML libraries
torch>=1.12.0
torchvision>=0.13.0
numpy>=1.21.0
scipy>=1.7.0
scikit-learn>=1.1.0
pandas>=1.4.0

# Computer Vision
opencv-python>=4.6.0
pillow>=9.0.0
matplotlib>=3.5.0
seaborn>=0.11.0

# YOLO and Object Detection
ultralytics>=8.0.0
supervision>=0.3.0

# Image Processing
pdf2image>=1.16.0
pytesseract>=0.3.9
python-bidi>=0.4.2
arabic-reshaper>=2.1.4

# PDF Processing
PyPDF2>=3.0.0
pdfplumber>=0.7.4
fitz>=0.0.1
pymupdf>=1.20.0

# Web Framework
flask>=2.1.0
flask-cors>=3.0.10
gunicorn>=20.1.0
requests>=2.28.0

# Utilities
tqdm>=4.64.0
click>=8.1.0
colorama>=0.4.5
loguru>=0.6.0
pyyaml>=6.0
configparser>=5.2.0

# Async Processing
aiofiles>=0.8.0
asyncio>=3.4.3

# Data Visualization
plotly>=5.10.0
bokeh>=2.4.0

# Progress and Monitoring
rich>=12.0.0
alive-progress>=2.4.0

# Text Processing
regex>=2022.7.0
unicodedata2>=14.0.0

# Testing
pytest>=7.1.0
pytest-asyncio>=0.19.0

# Optional: Transkribus integration
requests-oauthlib>=1.3.1

# Optional: Database
sqlalchemy>=1.4.0
sqlite3
EOF

# 9. Python paketleri kurulumu
log "⚙️  Python paketleri kuruluyor... (Bu işlem 5-10 dakika sürebilir)"
pip install -r requirements.txt >> $LOG_FILE 2>&1

# 10. Dizin yapısı oluşturma
log "📂 Proje dizin yapısı oluşturuluyor..."
mkdir -p {
    data/{raw,processed,datasets,models,outputs,cache},
    src/{core,detection,analysis,utils,api,web},
    config,
    logs,
    tests/{unit,integration},
    docs,
    scripts,
    weights,
    uploads,
    results
}

# __init__.py dosyaları
touch src/__init__.py
touch src/core/__init__.py
touch src/detection/__init__.py
touch src/analysis/__init__.py
touch src/utils/__init__.py
touch src/api/__init__.py
touch src/web/__init__.py
touch tests/__init__.py

# 11. Konfigürasyon dosyaları
log "⚙️  Konfigürasyon dosyaları oluşturuluyor..."

# Ana config
cat > config/config.yaml << 'EOF'
# Ottoman Miner Configuration
app:
  name: "Ottoman Miner"
  version: "1.0.0"
  debug: false

paths:
  data_dir: "data"
  models_dir: "weights"
  outputs_dir: "results"
  logs_dir: "logs"

yolo:
  confidence_threshold: 0.5
  nms_threshold: 0.4
  input_size: [608, 1152]
  model_path: "weights/ottoman_yolov4.weights"
  config_path: "weights/ottoman_yolov4.cfg"

processing:
  batch_size: 4
  max_workers: 4
  use_gpu: false
  
logging:
  level: "INFO"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  
web:
  host: "0.0.0.0"
  port: 5000
  upload_folder: "uploads"
  max_file_size: 16777216  # 16MB
EOF

# Logging config
cat > config/logging.yaml << 'EOF'
version: 1
formatters:
  default:
    format: '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
handlers:
  console:
    class: logging.StreamHandler
    level: DEBUG
    formatter: default
    stream: ext://sys.stdout
  file:
    class: logging.FileHandler
    level: INFO
    formatter: default
    filename: logs/ottoman_miner.log
loggers:
  ottoman_miner:
    level: DEBUG
    handlers: [console, file]
    propagate: no
root:
  level: INFO
  handlers: [console]
EOF

# 12. Aktivasyon script'leri
log "🔗 Aktivasyon script'leri oluşturuluyor..."

# Bash aktivasyon
cat > activate.sh << 'EOF'
#!/bin/bash
cd ~/ottoman-project
source ottoman_env/bin/activate
export PYTHONPATH="${PYTHONPATH}:$(pwd)/src"
echo "✅ Ottoman Miner ortamı aktive edildi!"
echo "📍 Dizin: $(pwd)"
echo "🐍 Python: $(which python)"
echo "📦 Paketler: $(pip list | wc -l) adet kurulu"
echo ""
echo "🚀 Kullanım:"
echo "   python src/main.py --help"
echo "   python src/api/app.py  # Web arayüzü"
echo ""
EOF
chmod +x activate.sh

# Fish shell desteği
cat > activate.fish << 'EOF'
#!/usr/bin/env fish
cd ~/ottoman-project
source ottoman_env/bin/activate.fish
set -x PYTHONPATH $PYTHONPATH:(pwd)/src
echo "✅ Ottoman Miner (Fish) ortamı aktive edildi!"
EOF
chmod +x activate.fish

# 13. Test script'i
cat > test_installation.py << 'EOF'
#!/usr/bin/env python3
"""
Ottoman Miner Kurulum Test Script'i
"""
import sys
import importlib
import platform

def test_imports():
    """Temel kütüphaneleri test et"""
    required_packages = [
        'torch', 'torchvision', 'cv2', 'numpy', 'pandas',
        'PIL', 'matplotlib', 'sklearn', 'yaml', 'requests'
    ]
    
    print("🧪 Paket importları test ediliyor...")
    for package in required_packages:
        try:
            importlib.import_module(package)
            print(f"   ✅ {package}")
        except ImportError as e:
            print(f"   ❌ {package}: {e}")
            return False
    return True

def test_opencv():
    """OpenCV test"""
    try:
        import cv2
        print(f"🖼️  OpenCV: {cv2.__version__}")
        return True
    except Exception as e:
        print(f"❌ OpenCV hatası: {e}")
        return False

def test_torch():
    """PyTorch test"""
    try:
        import torch
        print(f"🔥 PyTorch: {torch.__version__}")
        print(f"   CUDA: {torch.cuda.is_available()}")
        return True
    except Exception as e:
        print(f"❌ PyTorch hatası: {e}")
        return False

def main():
    print("🔍 OTTOMAN MINER KURULUM KONTROLÜ")
    print("=" * 40)
    print(f"🖥️  Platform: {platform.platform()}")
    print(f"🐍 Python: {sys.version}")
    print()
    
    tests = [test_imports, test_opencv, test_torch]
    passed = 0
    
    for test in tests:
        if test():
            passed += 1
        print()
    
    print(f"📊 Sonuç: {passed}/{len(tests)} test başarılı")
    
    if passed == len(tests):
        print("🎉 Kurulum başarılı! Ottoman Miner kullanıma hazır.")
        return True
    else:
        print("⚠️  Bazı testler başarısız. Kurulumu kontrol edin.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# 14. Sistem servisi (opsiyonel)
cat > scripts/ottoman_service.sh << 'EOF'
#!/bin/bash
# Ottoman Miner sistem servisi

case "$1" in
    start)
        echo "🚀 Ottoman Miner başlatılıyor..."
        cd ~/ottoman-project
        source ottoman_env/bin/activate
        nohup python src/api/app.py > logs/service.log 2>&1 &
        echo $! > logs/ottoman.pid
        echo "✅ Servis başlatıldı (PID: $(cat logs/ottoman.pid))"
        ;;
    stop)
        echo "🛑 Ottoman Miner durduruluyor..."
        if [ -f logs/ottoman.pid ]; then
            kill $(cat logs/ottoman.pid)
            rm logs/ottoman.pid
            echo "✅ Servis durduruldu"
        else
            echo "⚠️  Servis zaten durmuş"
        fi
        ;;
    restart)
        $0 stop
        sleep 2
        $0 start
        ;;
    status)
        if [ -f logs/ottoman.pid ] && kill -0 $(cat logs/ottoman.pid) 2>/dev/null; then
            echo "✅ Servis çalışıyor (PID: $(cat logs/ottoman.pid))"
        else
            echo "❌ Servis durmuş"
        fi
        ;;
    *)
        echo "Kullanım: $0 {start|stop|restart|status}"
        exit 1
        ;;
esac
EOF
chmod +x scripts/ottoman_service.sh

# 15. Final kontrolü
log "🧪 Kurulum test ediliyor..."
source ottoman_env/bin/activate
python test_installation.py

# 16. Kurulum özeti
cat << 'EOF'

╔══════════════════════════════════════════════════════════════════╗
║                     🎉 KURULUM TAMAMLANDI! 🎉                  ║
╚══════════════════════════════════════════════════════════════════╝

📍 Proje Dizini: ~/ottoman-project
🐍 Python Ortamı: ottoman_env
📊 Kurulu Paket Sayısı: 50+

🚀 KULLANIMA BAŞLAMA:
   cd ~/ottoman-project
   source ottoman_env/bin/activate
   # veya
   ./activate.sh

📋 SONRAKI ADIMLAR:
   1. YOLOv4 model dosyalarını indirme
   2. Ottoman karakter tanıma modelini kurma  
   3. Web arayüzünü başlatma
   4. Test belgeleri ile deneme

📞 DESTEK:
   Log dosyası: /tmp/ottoman_setup.log
   Test script'i: python test_installation.py

EOF

log "✅ ADIM 1 başarıyla tamamlandı!"
log "📝 Log dosyası: $LOG_FILE"
log "🔜 ADIM 2 için hazır!"

# Aktivasyon reminder
echo ""
echo "💡 Şimdi çalıştırın:"
echo "   cd ~/ottoman-project && ./activate.sh"
EOF