Example = {}

local KVP_POSITION = 'position'

function Example.Clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

function Example.Round(value, decimals)
    local mult = 10 ^ (decimals or 0)
    return math.floor(value * mult + 0.5) / mult
end

function Example.IsMetric()
    return ShouldUseMetricMeasurements()
end

function Example.FormatSpeed(metersPerSecond)
    if Example.IsMetric() then
        return ('%d KM/H'):format(math.floor(metersPerSecond * 3.6 + 0.5))
    end
    return ('%d MPH'):format(math.floor(metersPerSecond * 2.236936 + 0.5))
end

function Example.Label(text)
    local label = GetLabelText(text)
    if label == 'NULL' then return text end
    return label
end

function Example.GetPosition(default)
    local stored = GetResourceKvpString(KVP_POSITION)
    if stored and stored ~= '' then return stored end
    return default
end

function Example.SetPosition(position)
    SetResourceKvp(KVP_POSITION, position)
end
