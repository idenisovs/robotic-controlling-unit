#ifndef FIELDS_H
#define	FIELDS_H

// Протокол передачи данных Оператор <-> Контроллер
// Поля сообщения
#define MSG_NUM         0       // Номер сообщения.
#define MSG_TYPE        1       // Тип сообщения.
#define MSG_HIGH        2       // Поле данных, 2-ой октет.
#define MSG_LOW         3       // Поле данных, 1-ый октет.
// Типы сообщений
#define MSG_HELLO       1       // Приветствие
#define MSG_TEST        2       // Проверка связи
#define MSG_POS_X       3       // Позиция манипулятора, ось Х
#define MSG_POS_Y       4       // Позиция манипулятора, ось Y
#define MSG_POS_Z       5       // Позиция манипулятора, ось Z
#define MSG_OK          6       // Подтверждение приёма.
#define MSG_OK_TP       7       // Показания температуры и давления датчиков.
#define MSG_OK_LR       8       // Нагрузка (А) левого и правого двиг.
#define MSG_OK_S        9       // Статусное сообщение.
#define MSG_OK_VV       11      // Напряжение двигателей
#define MSG_JOY_BTN     12      // Состояние кнопок джойстика. 
#define MSG_ERROR       10      // Сообщение об ошибке.
#define MSG_BYE         255     // Завершение сессии.
// Типы ошибок
#define MSG_ERR_UNKN    1       // Неизвестный тип сообщения.

#define STATUS_MCU      0       // Бит 1: Связь с МК нет(0)/есть(1)
#define STATUS_BATT     1       // Бит 2: Батарея норм(0)/разряж(1)

#endif	/* FIELDS_H */

