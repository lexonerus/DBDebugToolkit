# Response Body Copy Functionality

## Overview
Добавлена возможность полностью скопировать response body из сетевых запросов в DBDebugToolkit. Функциональность доступна в нескольких местах интерфейса для удобства использования.

## Features

### 1. Copy Button in Body Preview
- В `DBBodyPreviewViewController` добавлена кнопка "Copy" в правом верхнем углу
- Позволяет скопировать содержимое body (request или response) в буфер обмена
- Поддерживает JSON, текст и изображения (для изображений показывается сообщение о невозможности копирования)

### 2. Copy Option in Request Details
- В `DBRequestDetailsViewController` добавлена опция "Copy body to clipboard" в секции Body
- Доступна для каждого типа body (request/response)
- Показывает уведомление об успешном копировании

### 3. Long Press Menu in Network List
- В `DBNetworkViewController` добавлено длительное нажатие на ячейки запросов
- Показывает меню с опциями копирования request и response body
- Автоматически определяет доступность body для копирования

## Implementation Details

### DBBodyPreviewViewController
- Добавлена кнопка "Copy" в navigation bar
- Сохраняет текущий body text и data для копирования
- Обрабатывает различные типы данных (JSON, текст, изображения)

### DBRequestDetailsViewController
- Добавлена ячейка "Copy body to clipboard" в секцию Body
- Увеличено количество строк в секции Body с 2 до 3
- Реализован метод `copyBodyToClipboard` для копирования

### DBNetworkViewController
- Добавлен UILongPressGestureRecognizer для обработки длительных нажатий
- Реализованы методы `copyRequestBodyForRequest` и `copyResponseBodyForRequest`
- Динамическое меню с доступными опциями копирования

## Usage

### Method 1: From Body Preview
1. Откройте детали запроса
2. Перейдите на вкладку Request или Response
3. Нажмите "Body preview"
4. В открывшемся окне нажмите кнопку "Copy" в правом верхнем углу

### Method 2: From Request Details
1. Откройте детали запроса
2. Перейдите на вкладку Request или Response
3. В секции Body нажмите "Copy body to clipboard"

### Method 3: From Network List
1. В списке сетевых запросов нажмите и удерживайте на нужной ячейке
2. В появившемся меню выберите "Copy Request Body" или "Copy Response Body"

## Supported Data Types

- **JSON**: Красиво отформатированный JSON с правильным экранированием
- **Text**: UTF-8 текст или hex-представление для бинарных данных
- **Images**: Показывается сообщение о невозможности копирования (можно сделать скриншот)

## User Feedback

- Показываются уведомления об успешном копировании
- Отображаются сообщения об ошибках (нет содержимого, изображения)
- Все уведомления показываются на главном потоке

## Technical Notes

- Используется `UIPasteboard` для копирования в буфер обмена
- Асинхронное чтение body данных через completion blocks
- Поддержка iPad с правильным позиционированием popover меню
- Обработка различных состояний body (загружается, готов, ошибка)
