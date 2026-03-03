# Prediction Service 검증 결과

**검증 일시**: 2026-03-03  
**환경**: 로컬 (prediction-service 8000, data-collector 8001 기동)  
**Shrimp 태스크**: 태스크 단위·로직 검증 6건 수행

---

## 1. 검증 요약

| 항목 | 결과 | 비고 |
|------|------|------|
| 서비스 단독 API | 통과 | run-python-qa.ps1 4항목 통과 |
| 로직 (LSTM vs Mock·헬스) | 검증 완료 | 코드 검토로 분기·헬스 동작 확인 |
| Backend 연동 (isModelReady·Ops 헬스) | 검증 완료 | FastApiPredictionClient·OpsHealthService·OpsModelStatusService 코드 확인 |
| AnalysisService 예측·fallback | 검증 완료 | aiServiceEnabled·onErrorResume·buildAnalysisResponse 확인 |
| 자동 검증 스크립트 | 통과 | run-python-qa.ps1 실행 성공 |

---

## 2. 서비스 단독 API (Task 1)

- **GET /**  
  - 200, `service`, `version`, `status`(running) 확인
- **GET /api/v1/health**  
  - 200, `status`: ok, `service`: ai-prediction-service
- **POST /api/v1/predict**  
  - 최소 body: `{"symbol":"005930","predictionMinutes":60}`  
  - 응답: symbol, currentPrice, predictedPrice, confidence, direction, modelType, predictionMinutes
- **POST /api/v1/predict/batch**  
  - 배열 길이·symbol 순서 검증

**실행**: `.\scripts\run-python-qa.ps1` (QA_PREDICTION_URL=http://localhost:8000)

---

## 3. 로직 검증 (Task 2)

- **health_check**  
  - `get_model()` 호출 없음. 모델 유무와 무관하게 200, `status`: ok 반환.
- **predict_price**  
  - `request.series` 존재 및 `len(series) >= (request.lookbackDays or 30)` 이고 `get_model() is not None`일 때만 LSTM 추론.
  - 그 외(series 없음, 길이 부족, 모델 없음, `preprocess_series_for_serving` 반환 `x.size == 0`) → `_mock_response(request)`.
- **predictor.get_model()**  
  - `MODEL_PATH` 또는 `LSTM_MODEL_PATH` 미설정 또는 해당 경로에 파일 없으면 `None` 반환 → Mock 사용.

---

## 4. Backend 연동 (Task 3)

- **FastApiPredictionClient.isModelReady()**  
  - `GET {baseUrl}/api/v1/health` 호출 후 `getStatusCode().is2xxSuccessful()` → true/false.
- **OpsHealthService.checkPredictionService()**  
  - `aiPredictionClient.isModelReady().defaultIfEmpty(false).block()` → true면 UP, 아니면 DOWN.
- **OpsModelStatusService.getStatus()**  
  - 동일하게 `aiPredictionClient.isModelReady()` 사용, `modelReady`·`serviceUrl`·`lastCheckAt` 반환.

---

## 5. AnalysisService 예측·fallback (Task 4)

- **aiServiceEnabled == true**  
  - `lookbackDays`, `resolveDailySeries`, `resolveCurrentPrice`로 `PredictionRequestDto` 빌드.
  - `aiPredictionClient.predictPrice(predictionRequest)` 호출.
- **실패 시**  
  - `.onErrorResume(error -> Mono.empty())`, `.block()` 후 `aiPrediction == null`.
  - `buildAnalysisResponse(request, technicalAnalysis, aiPrediction)`에 null 전달 → 기술적 분석만으로 응답 생성.

---

## 6. 자동 검증·테스트 (Task 5)

- **run-python-qa.ps1**  
  - prediction 관련 4검증 항목 통과.
- **pytest**  
  - `investment-prediction-service`에서 `pytest tests/test_api.py -v` 실행 시 TestHealthApi, TestPredictApi, TestPredictBatchApi 검증 (CI 또는 로컬 venv 권장).

---

## 7. 참고

- 검증 가이드: `.cursor/plans/` 내 Prediction Service 검증 가이드 계획서 참조.
- development-status: 본 검증 완료 후 필요 시 `02-development-status.md` §1 완료 항목에 “Prediction Service 태스크 단위·로직 검증” 추가 가능.
