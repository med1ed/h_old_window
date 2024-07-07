blip = {}
    blip.get_coords = function(sprite, color, _s)
        if sprite == nil then sprite = 0; end;
        if color == nil then color = -1 end;

        local _blip = HUD.GET_FIRST_BLIP_INFO_ID(sprite);
        if not HUD.DOES_BLIP_EXIST(_blip) then
            _blip = HUD.GET_NEXT_BLIP_INFO_ID(sprite);
        end

        if (HUD.DOES_BLIP_EXIST(_blip) or (color ~= -1) or (HUD.GET_BLIP_COLOUR(_blip) ~= color)) then
            local _pos = HUD.GET_BLIP_COORDS(_blip);
            return _pos;
        end
        return 0;
    end

streaming = {}
    streaming.request_model = function(_hash, _s) 
        if (STREAMING.IS_MODEL_VALID(_hash)) then
            while not STREAMING.HAS_MODEL_LOADED(_hash) do
                STREAMING.REQUEST_MODEL(_hash);
                _s:yield();
                return STREAMING.HAS_MODEL_LOADED(_hash);
            end
        else
            log.warning("[ h ] Invalid model: " .. tostring(_hash));
            return false;
        end

        return STREAMING.HAS_MODEL_LOADED(_hash);
    end

    streaming.request_control = function(_entity, _s) 
        if not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(_entity) then
            local network_entity_id = NETWORK.NETWORK_GET_NETWORK_ID_FROM_ENTITY(_entity);
            NETWORK.SET_NETWORK_ID_CAN_MIGRATE(network_entity_id, true);
            local _req = 0;
            while ( _req < 25 and not NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(_entity)) do
                NETWORK.NETWORK_REQUEST_CONTROL_OF_ENTITY(_entity); 
                _req = _req + 1
                log.info(tostring(_req) .. " " .. _entity .. " " .. tostring(NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(_entity)))
                _s:yield();
            end
            return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(_entity);
        else
            return NETWORK.NETWORK_HAS_CONTROL_OF_ENTITY(_entity);
        end
    end


ped = {}
    ped.copy_outfit = function(_ped)
        local _myPed = PLAYER.PLAYER_PED_ID();
        if (ENTITY.GET_ENTITY_MODEL(_myPed) ~= ENTITY.GET_ENTITY_MODEL(_ped)) then
            log.warning("h: ped.copy_outfit: models dont match");
            return 
        end 

        for _id = 0, 11 do
            local _componentID = PED.GET_PED_DRAWABLE_VARIATION(_ped, _id);
            local _componentTextures = PED.GET_PED_TEXTURE_VARIATION(_ped, _id);
            local _componentPalette = PED.GET_PED_PALETTE_VARIATION(_ped, _id);

            PED.SET_PED_COMPONENT_VARIATION(_myPed, _id, _componentID, _componentTextures, _componentPalette);
        end

        for _id = 0, 7 do
            local _propID = PED.GET_PED_PROP_INDEX(_ped, _id);
            local _propTexture = PED.GET_PED_PROP_TEXTURE_INDEX(_ped, _id);

            PED.SET_PED_PROP_INDEX(_myPed, _id, _propID, _propTexture, true, 1);
        end
    end

    ped.copy_face = function(_ped)
        local _myPed = PLAYER.PLAYER_PED_ID();
        if (ENTITY.GET_ENTITY_MODEL(_myPed) ~= ENTITY.GET_ENTITY_MODEL(_ped)) then
            log.warning("h: ped.copy_face: models dont match");
            return 
        end 

        local _shapeFirstIDRef = {};
        local _shapeSecondIDRef = {};
        local _shapeThirdIDRef = {};
        local _skinFirstIDRef = {};
        local _skinSecondIDRef = {};
        local _skinThirdIDRef = {};
        local _shapeMixRef = {};
        local _skinMixRef = {};
        local _thirdMixRef = {};
        local _isParent = {};   

        local _headBlendDataRef = {}

        PED.GET_PED_HEAD_BLEND_DATA(_ped, _headBlendDataRef);

        log.info(tostring(_headBlendDataRef.shapeFirstID))

        -- PED.SET_PED_HEAD_BLEND_DATA(_myPed, )
    end

    ped.copy_ped = function(_ped)
        ped.copy_outfit(_ped)
        ped.copy_face(_ped)
    end

vehicle = {}
    vehicle.repaire = function(_vehicle)
        VEHICLE.SET_VEHICLE_UNDRIVEABLE(_vehicle, false)
        if FIRE.IS_ENTITY_ON_FIRE(_vehicle) then
            FIRE.STOP_ENTITY_FIRE(_vehicle);
        end

        for k = 1, 5 do VEHICLE.SET_VEHICLE_TYRE_FIXED(_vehicle, k); end
        for k = 45, 47 do VEHICLE.SET_VEHICLE_TYRE_FIXED(_vehicle, k); end

        VEHICLE.SET_VEHICLE_FIXED(_vehicle);;
        VEHICLE.SET_VEHICLE_ENGINE_HEALTH(_vehicle, 1000);
        VEHICLE.SET_VEHICLE_ENGINE_ON(_vehicle, true, false, false);
    end

    vehicle.perfomance_tuning = function(_vehicle)
        for k = 11, 16 do
            local _numMods = VEHICLE.GET_NUM_VEHICLE_MODS(_vehicle, k);
            VEHICLE.SET_VEHICLE_MOD(_vehicle, k, _numMods - 1, false);
        end

        VEHICLE.SET_VEHICLE_MOD(_vehicle, 18, VEHICLE.GET_NUM_VEHICLE_MODS(_vehicle, 18), false );
    end

    vehicle.random_tuning = function(_vehicle)
        local _hash = ENTITY.GET_ENTITY_MODEL(_vehicle)
        if (VEHICLE.IS_THIS_MODEL_A_BIKE(_hash)) then
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(_vehicle, 6);
        else
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(_vehicle, math.random(0,13));
        end

        for k = 0, 50 do 
            VEHICLE.TOGGLE_VEHICLE_MOD(_vehicle, k, true);

            local _numMods = VEHICLE.GET_NUM_VEHICLE_MODS(_vehicle, k);
            VEHICLE.SET_VEHICLE_MOD(_vehicle, k, math.random(-1, _numMods - 1), false );
        end

        VEHICLE.SET_VEHICLE_COLOURS(_vehicle, math.random(0, 160), math.random(0, 160))
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(_vehicle, math.random(0, 160), math.random(0, 160))
        VEHICLE.SET_VEHICLE_WINDOW_TINT(_vehicle, math.random(0, 7))

        for k = 0, 3 do VEHICLE.SET_VEHICLE_NEON_ENABLED(_vehicle, k, math.random(0, 1)) end
        VEHICLE.SET_VEHICLE_NEON_COLOUR(_vehicle, math.random(0,254), math.random(0,254), math.random(0,254))
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(_vehicle, math.random(0,254), math.random(0,254), math.random(0,254))
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(_vehicle, math.random(0,12))
        VEHICLE.SET_VEHICLE_LIVERY(_vehicle, math.random(0,1))
    end

    vehicle.downgrade_tuning = function(_vehicle)
        local _hash = ENTITY.GET_ENTITY_MODEL(_vehicle)
        if (VEHICLE.IS_THIS_MODEL_A_BIKE(_hash)) then
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(_vehicle, 6);
        else
            VEHICLE.SET_VEHICLE_WHEEL_TYPE(_vehicle, 0);
        end

        for k = 0, 50 do 
            VEHICLE.TOGGLE_VEHICLE_MOD(_vehicle, k, true);
            VEHICLE.SET_VEHICLE_MOD(_vehicle, k, -1, false);
        end

        VEHICLE.SET_VEHICLE_COLOURS(_vehicle, 0, 0)
        VEHICLE.SET_VEHICLE_EXTRA_COLOURS(_vehicle, 0, 0)

        VEHICLE.SET_VEHICLE_WINDOW_TINT(_vehicle, 0)
        for k = 0, 3 do VEHICLE.SET_VEHICLE_NEON_ENABLED(_vehicle, k, false) end
        VEHICLE.SET_VEHICLE_NEON_COLOUR(_vehicle, -1, -1, -1)
        VEHICLE.SET_VEHICLE_TYRE_SMOKE_COLOR(_vehicle, -1, -1, -1)
        VEHICLE.SET_VEHICLE_XENON_LIGHT_COLOR_INDEX(_vehicle, -1)
        VEHICLE.SET_VEHICLE_LIVERY(_vehicle, -1)
    end

    vehicle.clone = function(_vehicle, _coords, _rot)
        log.warning("h: vehicle.clone: Invalid func"); return

        -- if (_vehicle == nil) then log.warning("h: vehicle.clone: Invalid _vehicle"); return end
        -- if (_coords == nil) then _coords = ENTITY.GET_ENTITY_COORDS(_vehicle, true); end
        -- if (_rot == nil) then _rot = ENTITY.GET_ENTITY_ROTATION(_vehicle, 2); end

        -- local _vehHash = ENTITY.GET_ENTITY_MODEL(_vehicle);

        -- if (not STREAMING.HAS_MODEL_LOADED(_vehHash)) then
        --     streaming.request_model(_vehHash)
        -- end
    end

entity = {}    
    entity.teleport = function(_entity, _x, _y, _z)
        local _getVehicle = PED.GET_VEHICLE_PED_IS_USING(_entity);
         
        if (PED.IS_PED_IN_VEHICLE(_entity, _getVehicle, true)) then
            _entity = _getVehicle;
        end

        ENTITY.SET_ENTITY_COORDS_NO_OFFSET(_entity, _x, _y, _z + 1, false, false, false);
    end

    entity.remove = function(_entity)
        if (ENTITY.DOES_ENTITY_EXIST(_entity)) then

            ENTITY.SET_ENTITY_VISIBLE(_entity, false, false)
            ENTITY.DETACH_ENTITY(_entity, false, false)
            ENTITY.SET_ENTITY_AS_NO_LONGER_NEEDED(_entity)
            ENTITY.SET_ENTITY_COORDS(_entity, 10000, 10000, 0, false, false, false, true)            
            ENTITY.DELETE_ENTITY(_entity)

            if (ENTITY.DOES_ENTITY_EXIST(_entity)) then
                return false;
            end

            return true;
        end
    end

draw = {}
    draw.rgba_to_hex = function(r, g, b, a)
        local rgb = {r, g, b, a};
        local hexadecimal = '#';
    
        for key = 1, #rgb do
            local value = rgb[key];
            local hex = '';
    
            while (value > 0) do
                local index = math.fmod(value, 16) + 1;
                value = math.floor(value / 16);
                hex = string.sub('0123456789ABCDEF', index, index) .. hex;
            end
    
            if (string.len(hex) == 0) then
                hex = '00';
            elseif (string.len(hex) == 1) then
                hex = '0' .. hex;
            end
            hexadecimal = hexadecimal .. hex;
        end
    
        return "#" .. hexadecimal;
    end

    draw.ray_cast = function()
        local _camCoords = CAM.GET_GAMEPLAY_CAM_COORD();
        local _camRot = CAM.GET_GAMEPLAY_CAM_ROT(2);
        local _dir = misc.rot_to_dir(_camRot);

        local _farCoords = {
            x = _camCoords.x + _dir.x * 1000,
            y = _camCoords.y + _dir.y * 1000,
            z = _camCoords.z + _dir.z * 1000
        }

        local _ray = SHAPETEST.START_EXPENSIVE_SYNCHRONOUS_SHAPE_TEST_LOS_PROBE(_camCoords.x, _camCoords.y, _camCoords.z, _farCoords.x, _farCoords.y, _farCoords.z, -1, 0, 7)

        local _rayHitRef = {};
        local _rayEndCoords = {};
        local _raySurfaceNormal = {};
        local _rayEntityHitRef = {};
        SHAPETEST.GET_SHAPE_TEST_RESULT(_ray, _rayHitRef, _rayEndCoords, _raySurfaceNormal, _rayEntityHitRef);

        local _returnRay = { HitRef = _rayHitRef.result, EndCoords = _rayEndCoords.result, SurfaceNormal = _raySurfaceNormal.result, EntityHitRef = _rayEntityHitRef.result}
        return _returnRay;
    end

    draw.marker = function( _type, x, y, z, dist, rot, r, g, b, a)
        GRAPHICS.DRAW_MARKER(_type, x, y, z + (dist / 2), 0, 0, 0, 0, 0, rot.z, (dist / 15), (dist / 15), (dist/15), r, g, b, a, false, false, 2, rot.z, nil, nil, false);
        GRAPHICS.DRAW_LINE(x, y, z + (dist/2), x, y, z-5, r, g, b, a);
    end

    draw.entity_box = function(_entity, r, g, b)
        if _entity == nil then return end
        if r == nil then r = 200; end
        if g == nil then g = 200; end
        if b == nil then b = 200; end

        if not ENTITY.DOES_ENTITY_EXIST(_entity) then return; end
    
        local _sizeMinRef = {};
        local _sizeMaxRef = {};
        local _modelHash = ENTITY.GET_ENTITY_MODEL(_entity)
        MISC.GET_MODEL_DIMENSIONS(_modelHash, _sizeMinRef, _sizeMaxRef);
    
        local _sizeMin = _sizeMinRef.result;
        local _sizeMax = _sizeMaxRef.result;

        local upper_left_rear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, -_sizeMax.x, -_sizeMax.y, _sizeMax.z);
        local upper_right_rear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, _sizeMin.x, -_sizeMax.y, _sizeMax.z);
        local lower_left_rear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, -_sizeMax.x, -_sizeMax.y, -_sizeMin.z);
        local lower_right_rear = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, _sizeMin.x, -_sizeMax.y, -_sizeMin.z);

        local upper_left_front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, -_sizeMax.x, _sizeMin.y, _sizeMax.z);
        local upper_right_front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, _sizeMin.x, _sizeMin.y, _sizeMax.z);
        local lower_left_front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, -_sizeMax.x, _sizeMin.y, -_sizeMin.z);
        local lower_right_front = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(_entity, _sizeMin.x, _sizeMin.y, -_sizeMin.z);

        GRAPHICS.DRAW_LINE(upper_left_rear.x, upper_left_rear.y, upper_left_rear.z, upper_right_rear.x, upper_right_rear.y, upper_right_rear.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(lower_left_rear.x, lower_left_rear.y, lower_left_rear.z, lower_right_rear.x, lower_right_rear.y, lower_right_rear.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(upper_left_rear.x, upper_left_rear.y, upper_left_rear.z, lower_left_rear.x, lower_left_rear.y, lower_left_rear.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(upper_right_rear.x, upper_right_rear.y, upper_right_rear.z, lower_right_rear.x, lower_right_rear.y, lower_right_rear.z, r, g, b, 255);
    
        GRAPHICS.DRAW_LINE(upper_left_front.x, upper_left_front.y, upper_left_front.z, upper_right_front.x, upper_right_front.y, upper_right_front.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(lower_left_front.x, lower_left_front.y, lower_left_front.z, lower_right_front.x, lower_right_front.y, lower_right_front.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(upper_left_front.x, upper_left_front.y, upper_left_front.z, lower_left_front.x, lower_left_front.y, lower_left_front.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(upper_right_front.x, upper_right_front.y, upper_right_front.z, lower_right_front.x, lower_right_front.y, lower_right_front.z, r, g, b, 255);
    
        GRAPHICS.DRAW_LINE(upper_left_rear.x, upper_left_rear.y, upper_left_rear.z, upper_left_front.x, upper_left_front.y, upper_left_front.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(upper_right_rear.x, upper_right_rear.y, upper_right_rear.z, upper_right_front.x, upper_right_front.y, upper_right_front.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(lower_left_rear.x, lower_left_rear.y, lower_left_rear.z, lower_left_front.x, lower_left_front.y, lower_left_front.z, r, g, b, 255);
        GRAPHICS.DRAW_LINE(lower_right_rear.x, lower_right_rear.y, lower_right_rear.z, lower_right_front.x, lower_right_front.y, lower_right_front.z, r, g, b, 255);
    end

misc = {}
    misc.rot_to_dir = function(rot)
        local _radX = rot.x * 0.0174532924;
        local _radZ = rot.z * 0.0174532924;
        local _num = math.abs(math.cos(_radX));

        local _dir = {x, y, z};

        _dir.x = -math.sin(_radZ) * _num;
        _dir.y = math.cos(_radZ) * _num;
        _dir.z = math.sin(_radX);

        return _dir;        
    end

    misc.money_format = function(_num)
        local formattedNumber = tostring(_num);
        local length = #formattedNumber;
        local result = {};
        local count = 0;
    
        for i = length, 1, -1 do
            count = count + 1;
            table.insert(result, 1, formattedNumber:sub(i, i));
    
            if count == 3 and i ~= 1 then
                table.insert(result, 1, ".");
                count = 0;
            end
        end
    
        return table.concat(result);
    end

    local __bc = {1, 2, 3, 4, 5, 6, 14, 15, 16, 17, 24, 37, 69, 70, 85, 92, 99, 100, 106, 114, 115, 142, 241, 257, 261, 262, 329, 330, 331 }
    misc.block_control = function()
        for k, v in pairs(__bc) do 
            PAD.DISABLE_CONTROL_ACTION(0, v, true);
        end
    end
