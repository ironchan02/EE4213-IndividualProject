import os
import sys
import json
import threading
import string
import time
import re

from nltk import word_tokenize
from nltk.stem.porter import PorterStemmer

from PySide6.QtCore import QObject, Slot, Signal
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from selenium import webdriver
from selenium.common import NoSuchDriverException, NoSuchElementException
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from transformers import pipeline

SETTING_JSON_PATH = "./config/setting.json"
DATASET_JSON_PATH = "./data/comments.json"
RESULT_JSON_PATH = "./data/result.json"


class BackendController(QObject):
    redirectPage = Signal(str)
    popupMsg = Signal(str)
    seleniumDone = Signal(str)
    seleniumFail = Signal(str)
    analysisResult = Signal(str)

    def __int__(self):
        super().__init__()

    @Slot(str)
    def saveSetting(self, json_string):
        write_file(SETTING_JSON_PATH, json_string)

    @Slot(str)
    def changePage(self, page):
        self.redirectPage.emit(page)

    @Slot(str)
    def showPopup(self, msg):
        self.popupMsg.emit(msg)

    @Slot()
    def crawler(self):
        t1 = threading.Thread(target=self.selenium_run)
        t1.start()

    @Slot()
    def startAnalysis(self):
        t1 = threading.Thread(target=self.analysis)
        t1.start()

    def analysis(self):
        defaultModel = pipeline("text-classification")
        amazonModel = pipeline(model="LiYuan/amazon-review-sentiment-analysis")
        file = open(DATASET_JSON_PATH)
        data = json.load(file)
        comments = data["comments"]
        results = []
        porter = PorterStemmer()
        for comment in comments:
            filterComment = comment.lower()
            filterComment = "".join([char for char in filterComment if char not in string.punctuation])
            filterComment = word_tokenize(filterComment)
            filterComment = [porter.stem(word) for word in filterComment]
            filterComment = " ".join(filterComment)
            results.append({
                "comment": comment,
                "default": defaultModel(filterComment),
                "amazon": amazonModel(filterComment)
            })
        self.analysisResult.emit(json.dumps({"results": results}))

    def selenium_run(self):
        try:
            file = open(SETTING_JSON_PATH)
            data = json.load(file)
            service = Service(executable_path=data["driverPath"])
            driver = webdriver.Chrome(service=service)
            driver.get(data["productLink"])

            botTest = driver.find_elements(By.CSS_SELECTOR, ".a-button-text")
            if botTest and len(botTest) == 1 and botTest[0].get_attribute("textContent") == "Continue shopping":
                self.popupMsg.emit("Seems captcha block the website\nPlease enter the code to proceed")

            showCommentBtn = WebDriverWait(driver, sys.maxsize) \
                .until(EC.presence_of_element_located(
                (By.CSS_SELECTOR,
                 "#reviews-medley-footer > div.a-row.a-spacing-medium > a"
                 )
            )
            )
            showCommentBtn.click()
            driver.implicitly_wait(5)

            commentText = []

            isLastPage = False
            while not isLastPage:

                comments = driver.execute_script(
                    "return document.querySelectorAll(\"[data-hook=review-body] > span:not(.aok-hidden)\")")
                for comment in comments:
                    commentTextContent = comment.get_attribute("textContent")
                    if re.search("[A-Za-z0-9 _.,!\"'\/$]*", commentTextContent):
                        commentText.append(commentTextContent)
                try:
                    nextPage = driver.find_element(By.CSS_SELECTOR, ".a-last > a")
                    nextPage.click()
                    time.sleep(2)

                except NoSuchElementException:
                    isLastPage = True

            write_file("./data/comments.json", json.dumps({"comments": commentText}))
            driver.quit()
            self.seleniumDone.emit("Comment saved")
        except NoSuchElementException:
            self.seleniumFail.emit("No element found")
        except NoSuchDriverException:
            self.seleniumFail.emit("No driver found")
        except:
            self.seleniumFail.emit("Selenium fail")


def write_file(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w+') as file:
        file.write(text)


if not os.path.exists(SETTING_JSON_PATH) or os.path.getsize(SETTING_JSON_PATH) == 0:
    write_file(SETTING_JSON_PATH, json.dumps({"driverPath": "./chromedriver.exe",
                                              "productLink": "https://www.amazon.com/Melissa-Doug-30608-Barbeque-Grill/dp/B0BGQSNWYZ/?_encoding=UTF8&_encoding=UTF8&ref_=dlx_gate_sd_dcl_tlt_b4c13cc9_dt_pd_gw_unk&pd_rd_w=tvqS1&content-id=amzn1.sym.2ed7d12d-4886-42ac-ae8f-d4dd936eb1e6&pf_rd_p=2ed7d12d-4886-42ac-ae8f-d4dd936eb1e6&pf_rd_r=04SW9M1AWH5W3QBSH12H&pd_rd_wg=4dMzq&pd_rd_r=bbe49464-b1cc-42aa-aba3-94ee2a97e116"}))
if not os.path.exists(DATASET_JSON_PATH):
    write_file(DATASET_JSON_PATH, "")

if not os.path.exists(RESULT_JSON_PATH):
    write_file(RESULT_JSON_PATH, "")

backendController = BackendController()

app = QGuiApplication(sys.argv)
os.environ["QML_XHR_ALLOW_FILE_READ"] = "1"
os.environ["QML_XHR_ALLOW_FILE_WRITE"] = "1"
engine = QQmlApplicationEngine()
engine.quit.connect(app.quit)
engine.load('main.qml')

engine.rootObjects()[0].setProperty('backendController', backendController)
sys.exit(app.exec())
