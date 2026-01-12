-- ============================================
-- АВТОМАТИЧЕСКИЙ ЗАГРУЗЧИК СКРИПТА
-- Запустите этот скрипт ОДИН РАЗ в jjsploit
-- Он будет работать постоянно и автоматически загружать основной скрипт
-- ============================================

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- URL основного скрипта
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/5234234234gdfg/refs/heads/main/server_hopper.lua"

-- Проверяем доступность функций
if not getgenv then
    print("❌ getgenv недоступен!")
    return
end

print("═══════════════════════════════════════")
print("🔧 AutoLoader запущен!")
print("═══════════════════════════════════════")
print("📱 Этот скрипт будет работать постоянно")
print("📱 Он автоматически загрузит основной скрипт")
print("📱 при смене сервера")
print("═══════════════════════════════════════")

-- Флаг для предотвращения множественных запусков
if getgenv().AutoLoaderRunning then
    print("⚠️ AutoLoader уже запущен!")
    return
end
getgenv().AutoLoaderRunning = true

-- Функция загрузки основного скрипта
local function loadMainScript()
    print("📥 Загружаю основной скрипт с GitHub...")
    
    local success, script = pcall(function()
        return game:HttpGet(MAIN_SCRIPT_URL, true)
    end)
    
    if success and script and #script > 100 then
        print("✅ Скрипт получен, длина: " .. #script .. " символов")
        print("🔄 Выполняю скрипт...")
        
        local func, loadErr = loadstring(script)
        if func then
            func()
            print("✅ Скрипт успешно загружен и выполнен!")
            return true
        else
            print("❌ Ошибка компиляции: " .. tostring(loadErr))
            return false
        end
    else
        print("❌ Не удалось загрузить скрипт с GitHub")
        if not success then
            print("Ошибка: " .. tostring(script))
        end
        return false
    end
end

-- Проверяем, был ли телепорт
local function checkTeleport()
    local currentJobId = game.JobId
    local lastJobId = getgenv().LastJobId
    
    -- Если JobId изменился или это первый запуск
    if not lastJobId or lastJobId ~= currentJobId then
        if lastJobId then
            print("═══════════════════════════════════════")
            print("🔄 ОБНАРУЖЕНА СМЕНА СЕРВЕРА!")
            print("   Старый JobId: " .. tostring(lastJobId))
            print("   Новый JobId: " .. tostring(currentJobId))
            print("═══════════════════════════════════════")
        else
            print("🆕 Первый запуск на этом сервере")
            print("🆔 JobId: " .. tostring(currentJobId))
        end
        
        -- Сохраняем новый JobId
        getgenv().LastJobId = currentJobId
        
        -- Ждем немного для стабильности
        wait(2)
        
        -- Загружаем основной скрипт
        return loadMainScript()
    else
        return false
    end
end

-- Инициализация
local player = Players.LocalPlayer
if not player then
    print("⏳ Жду загрузки игрока...")
    player = Players.PlayerAdded:Wait()
end

print("✅ Игрок найден: " .. player.Name)
print("📍 PlaceId: " .. tostring(game.PlaceId))
print("🆔 JobId: " .. tostring(game.JobId))

-- Проверяем сразу при запуске
spawn(function()
    wait(3) -- Ждем немного для загрузки
    checkTeleport()
end)

-- Постоянная проверка каждые 3 секунды
spawn(function()
    while true do
        wait(3)
        
        local currentJobId = game.JobId
        local lastJobId = getgenv().LastJobId
        
        -- Если JobId изменился, загружаем скрипт
        if lastJobId and lastJobId ~= currentJobId then
            print("🔄 Обнаружена смена сервера через постоянную проверку!")
            getgenv().LastJobId = currentJobId
            wait(2)
            loadMainScript()
        end
    end
end)

-- Также проверяем при загрузке персонажа
if player then
    player.CharacterAdded:Connect(function()
        print("👤 Персонаж загружен!")
        wait(2)
        checkTeleport()
    end)
    
    if player.Character then
        spawn(function()
            wait(2)
            checkTeleport()
        end)
    end
end

print("✅ AutoLoader работает в фоновом режиме")
print("💡 Он будет автоматически загружать скрипт при смене сервера")
print("💡 Вы можете закрыть это окно, AutoLoader продолжит работать")
