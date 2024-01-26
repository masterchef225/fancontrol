#!/bin/bash

# Функция для проверки температуры процессора
get_cpu_temperature() {
  # Используем 'sensors' для получения температуры процессора
  temperature=$(sensors | awk '/temp1/ {print $2}' | cut -c2- | sed 's/°C//')
  # Возвращаем значение температуры
  echo "$temperature"
}

# Функция для управления портом USB с использованием hub-ctrl
control_usb_port() {
  # Параметры для hub-ctrl
  hub_ctrl_params="-h 1 -P 2"
  # Проверяем температуру процессора
  temperature=$(get_cpu_temperature)
  
  if (( $(echo "$temperature > 30" | bc -l) )); then
    # Если температура выше 30 градусов, включаем порт
    ./hub-ctrl $hub_ctrl_params -p 1
    echo "USB port is ON (temperature: $temperature)"
  else
    # Иначе, выключаем порт
    ./hub-ctrl $hub_ctrl_params -p 0
    echo "USB port is OFF (temperature: $temperature)"
  fi
}

# Запускаем команду при старте
./hub-ctrl -h 1 -P 2 -p 0

# Бесконечный цикл для проверки температуры и управления портом
while true; do
  control_usb_port
  # Пауза на 5 секунд перед следующей проверкой
  sleep 5
done
