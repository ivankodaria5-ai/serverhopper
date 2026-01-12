-- ============================================
-- АВТОМАТИЧЕСКИЙ ЗАГРУЗЧИК СКРИПТА
-- Этот скрипт должен быть настроен на AUTO-EXECUTE в jjsploit
-- ============================================

local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

-- URL основного скрипта
local MAIN_SCRIPT_URL = "https://raw.githubusercontent.com/ivankodaria5-ai/5234234234gdfg/refs/heads/main/server_hopper.lua"

print("🔗 URL основного скрипта: " .. MAIN_SCRIPT_URL)

-- Проверяем доступность функций
if not getgenv then
    print("❌ getgenv недоступен!")
    return
end

print("🔧 AutoLoader запущен!")

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
            print("🔄 Обнаружена смена сервера!")
            print("   Старый JobId: " .. tostring(lastJobId))
            print("   Новый JobId: " .. tostring(currentJobId))
        else
            print("🆕 Первый запуск на этом сервере")
        end
        
        -- Сохраняем новый JobId
        getgenv().LastJobId = currentJobId
        
        -- Ждем немного для стабильности
        wait(2)
        
        -- Загружаем основной скрипт
        return loadMainScript()
    else
        print("ℹ️ Телепорта не было, JobId: " .. tostring(currentJobId))
        return false
    end
end

-- Ждем загрузки игрока
local player = Players.LocalPlayer
if not player then
    print("⏳ Жду загрузки игрока...")
    player = Players.PlayerAdded:Wait()
end

print("✅ Игрок найден: " .. player.Name)
print("📍 PlaceId: " .. tostring(game.PlaceId))
print("🆔 JobId: " .. tostring(game.JobId))

-- Ждем загрузки персонажа (но не блокируем, если персонажа нет)
spawn(function()
    if not player.Character then
        print("⏳ Жду загрузки персонажа...")
        player.CharacterAdded:Wait()
        wait(2)
        print("✅ Персонаж загружен!")
    else
        print("✅ Персонаж уже загружен")
    end
    
    -- Проверяем телепорт и загружаем скрипт после загрузки персонажа
    local loaded = checkTeleport()
    
    if not loaded then
        print("⚠️ Скрипт не загрузился, возможно телепорта не было")
        print("💡 Если вы только что телепортировались, подождите несколько секунд")
        
        -- Пробуем еще раз через 5 секунд (на случай если JobId еще не обновился)
        spawn(function()
            wait(5)
            print("🔄 Повторная проверка...")
            checkTeleport()
        end)
    end
end)

-- Также проверяем сразу (на случай если персонаж уже загружен)
if player.Character then
    wait(1)
    local loaded = checkTeleport()
    if loaded then
        print("✅ Скрипт загружен сразу!")
    end
end

print("✅ AutoLoader завершил работу (проверка продолжается в фоне)")

