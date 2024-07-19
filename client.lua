local RSGCore = exports['rsg-core']:GetCoreObject()
local carryingEntity = nil
local carryingEntityNetId = nil

local lastNotificationTime = 0
local notificationCooldown = 30000 -- 30 seconds

function showDropNotification()
    RSGCore.Functions.Notify('Press E to drop the item', 'primary', 6000)
end

local function RequestModelWithTimeout(modelHash, timeout)
    RequestModel(modelHash)
    local startTime = GetGameTimer()
    while not HasModelLoaded(modelHash) do
        Citizen.Wait(100)
        if GetGameTimer() - startTime > timeout then
            return false
        end
    end
    return true
end

function createAndPickupObject(objectModel, targetCoords)
    if carryingEntity then
        RSGCore.Functions.Notify('You are already carrying something.', 'error', 3000)
        return
    end

    local modelHash = GetHashKey(objectModel)
    if not IsModelValid(modelHash) then
        RSGCore.Functions.Notify('Invalid object model.', 'error', 3000)
        return
    end

    if not RequestModelWithTimeout(modelHash, 20000) then
        RSGCore.Functions.Notify('Failed to load object model (timeout).', 'error', 3000)
        return
    end

    local object = CreateObject(modelHash, targetCoords.x, targetCoords.y, targetCoords.z, true, true, true)
    if DoesEntityExist(object) then
        carryEntity(object)
    else
        RSGCore.Functions.Notify('Failed to create object after loading model.', 'error', 3000)
    end

    SetModelAsNoLongerNeeded(modelHash)
end

function carryEntity(entity)
    carryingEntity = entity
    carryingEntityNetId = NetworkGetNetworkIdFromEntity(entity)
    local playerPed = PlayerPedId()

    local dict = "mech_carry_box"
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end

    TaskPlayAnim(playerPed, dict, "idle", 8.0, -8.0, -1, 31, 0, false, false, false)
    AttachEntityToEntity(entity, playerPed, GetPedBoneIndex(playerPed, 28422), 0.0, 0.6, -0.2, 0.0, 0.0, 0.0, true, true, false, true, 1, true)

    TriggerServerEvent('redm:syncEntityCarry', carryingEntityNetId, true)
    showDropNotification()
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if carryingEntity then
            if IsControlJustPressed(0, 0xCEFD9220) then -- 0xCEFD9220 is the control code for 'E'
                dropEntity()
            end

            local currentTime = GetGameTimer()
            if currentTime - lastNotificationTime > notificationCooldown then
                showDropNotification()
                lastNotificationTime = currentTime
            end
        end
    end
end)

function dropEntity()
    if carryingEntity then
        local playerPed = PlayerPedId()

        ClearPedTasks(playerPed)
        DetachEntity(carryingEntity, true, true)
        PlaceObjectOnGroundProperly(carryingEntity)

        TriggerServerEvent('redm:syncEntityCarry', carryingEntityNetId, false)

        carryingEntity = nil
        carryingEntityNetId = nil

        RSGCore.Functions.Notify('Object dropped.', 'success', 3000)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if carryingEntity then
            local playerPed = PlayerPedId()
            if not IsEntityPlayingAnim(playerPed, "mech_carry_box", "idle", 3) then
                TaskPlayAnim(playerPed, "mech_carry_box", "idle", 8.0, -8.0, -1, 31, 0, false, false, false)
            end
        end
    end
end)

Citizen.CreateThread(function()
    local itemModels = {
         "p_cs_sackcorn01x","p_cs_sackcorn01x", "p_crate02x", "p_chair_crate15x", "p_stoolfolding01x", "p_crate06x", "p_barrel05b", "p_tincan01x", "s_crateseat03x", "p_chair_crate02x",
        "mp001_p_cratetriple01x", "mp001_p_cratetwin01x", "mp001_p_group_crates01", "mp001_p_mp_artscrates01x", "mp001_p_mp_crate06x", "mp001_p_mp_cratebrand01x", "mp001_p_mp_cratetnt03x", "mp001_p_mp_crateweapon_01a", "mp004_mp_gfh_cratebooze01x", "mp004_mp_gfh_cratefuel01x", "mp004_mp_gfh_crategoods01x", "mp004_mp_gfh_cratetobacco01x", "mp004_mp_gfh_crateweapons01x", "mp004_p_cratetriple01x", "mp004_p_cratetwin01x", "mp005_mp_cratetrader01x", "mp005_mp_nondes_cratetrader01x", "mp005_p_mp_cratestack01x", "mp006_p_crate01x_nobrand", "mp006_p_mnshn_crate06x", "mp006_p_mnshn_crate12_01x", "mp006_p_moonshine_crate01x", "mp006_p_mp006_crate012x", "mp006_p_mp006_crate02x", "mp006_p_mp006_cratecanvase01x", "mp006_p_mp006_cratecover07x", "mp008_p_race_cratetriple01x", "mp008_p_race_cratetwin01x", "mp009_p_mp009_cratetable01x", "p_12moonshinecrate01", "p_bal_whiskeycrate01", "p_bat_cratestack01x", "p_bottlecrate01x", "p_bottlecrate02x", "p_bottlecrate02x_dirty", "p_bottlecrate03x", "p_bottlecrate05x", "p_bottlecrate_cul", "p_bottlecrate_hob", "p_bottlecrate_mil", "p_bottlecrate_sav", "p_bottlecrate_sur", "p_boxcar_barrelcrate01", "p_boxcar_cratecover05", "p_boxcar_cratecover09", "p_boxcar_crates01x", "p_boxcar_rob4_crates01x", "p_chair_crate02x", "p_crate012ax", "p_crate012x", "p_crate012x_sea", "p_crate01_h", "p_crate01x", "p_crate01x_var02", "p_crate02_h", "p_crate03b", "p_crate03c", "p_crate03d", "p_crate03x", "p_crate04x", "p_crate04x_b", "p_crate05x", "p_crate05x_group_01", "p_crate06bx", "p_crate08b", "p_crate08x", "p_crate14bx", "p_crate14cx", "p_crate14x", "p_crate15bx", "p_crate15x_a", "p_crate16x", "p_crate17x", "p_crate20x", "p_crate22x", "p_crate22x_a", "p_crate22x_s_group_01", "p_crate22x_small", "p_crate23x", "p_crate23x_group_01", "p_crate24x", "p_crate25x", "p_crate26bx", "p_crate26bx_a", "p_crate26bx_b", "p_crate26x", "p_crate26x_a", "p_crate26x_b", "p_crate26x_c", "p_crate27x", "p_crate_snow01x", "p_crateapple01x", "p_crateapple02x", "p_cratebanana01x", "p_cratebanana02x", "p_crategoods01x", "p_crategoods01x_empty", "p_crategoods01x_group_01", "p_crategoods02x", "p_crategoods02x_empty", "p_crategoods02x_group_01", "p_crategoods03x", "p_crategoods03x_group_01", "mp001_p_barreltriple01x", "mp001_p_barreltwin01x", "mp001_p_group_barrelshot01", "mp001_p_group_barrelshot02", "mp001_p_group_barrelshot03", "mp001_p_mp_jump_barrellong01", "mp001_p_mp_jump_barrelshort01", "mp001_p_mp_pickup_barrel_gun01a", "mp001_p_mp_pickup_barrel_gun02a", "mp001_p_mp_pickup_barrel_logo10x", "mp001_p_mp_pickup_barrel_logo11x", "mp001_p_mp_pickup_barrel_logo12x", "mp001_p_mp_pickup_barrel_logo13x", "mp001_p_mp_pickup_barrel_logo14x", "mp001_p_mp_pickup_barrel_logo15x", "mp001_p_mp_pickup_barrel_logo16x", "mp001_p_mp_pickup_barrel_logo17x", "mp001_p_mp_pickup_barrel_logo18x", "mp001_p_mp_pickup_barrel_logo19x", "mp001_p_mp_pickup_barrel_logo1x", "mp001_p_mp_pickup_barrel_logo20x", "mp001_p_mp_pickup_barrel_logo2x", "mp001_p_mp_pickup_barrel_logo3x", "mp001_p_mp_pickup_barrel_logo4x", "mp001_p_mp_pickup_barrel_logo5x", "mp001_p_mp_pickup_barrel_logo6x", "mp001_p_mp_pickup_barrel_logo7x", "mp001_p_mp_pickup_barrel_logo8x", "mp001_p_mp_pickup_barrel_logo9x", "mp004_p_barreltriple01x", "mp004_p_barreltwin01x", "mp005_s_posse_lardbarrels01x", "mp005_s_posse_lardbarrels02x", "mp006_p_mnshn_barrel02x", "mp006_p_mnshn_barrel03x", "mp006_p_mnshn_barrelgroup01x", "mp006_p_moonshine_barrel01x_dmg", "mp006_p_mp_moonshine_barrel01x", "mp006_p_mp_moonshine_barrel05x", "mp008_p_mnshn_barrelgroup01x", "mp008_p_race_barreltriple01x", "mp008_p_race_barreltwin01x", "p_ambburnbarrel01x", "p_barrel010x", "p_barrel01ax", "p_barrel01ax_sea", "p_barrel02_opencs01x", "p_barrel02x", "p_barrel02x_group_01", "p_barrel02x_group_02", "p_barrel02x_group_03", "p_barrel03x", "p_barrel04b", "p_barrel04x", "p_barrel05b", "p_barrel05x", "p_barrel06x", "p_barrel08x", "p_barrel09x", "p_barrel11x", "p_barrel12x", "p_barrel_cor01x", "p_barrel_cor01x_dmg", "p_barrel_cor02x", "p_barrel_ladle01x", "p_barrel_wash01x", "p_barrelapples01x", "p_barrelgroup01x", "p_barrelhalf01x", "p_barrelhalf02x", "p_barrelhalf03x", "p_barrelhalf04x", "p_barrelhalf05x", "p_barrelhalf06x", "p_barrelhalf07x", "p_barrelhalf08x", "p_barrelhalf09bx", "p_barrelhalf09bx_dmg", "p_barrelhalf09dx", "p_barrelhalfgroup01x", "p_barrelhoistnbx01x", "p_barrell1_h", "p_barrelladle1x_culture", "p_barrelladle1x_hobo", "p_barrelladle1x_military", "p_barrelladle1x_savage", "p_barrelladle1x_survivor", "p_barrellemons01x", "p_barrellt_h00", "p_barrellt_h01", "p_barrellt_h02", "p_barrellt_h03", "p_barrelmoonshine", "p_barreloranges01x", "p_barrelpears01x", "p_barrelpotatoes01x", "p_barrelrabbit01x", "p_barrelsalt01x", "p_barrelsaltlid01x", "p_barrelsaltlid01x_sea", "p_barrelshavingbase01x", "p_barreltobacco01x", "p_barrelwater01x", "p_biscuitbarrel01x", "p_boxcar_barrel_02a", "p_boxcar_barrel_09a", "p_boxcar_barrelcrate01", "p_cannonbarrel01x", "p_chair_barrel04b", "p_chickenbarrel01x", "p_chickenbarrel02x", "p_cs_barrel04x", "p_cs_barrel_ladle01x", "p_cs_chucksidebarrel03", "p_cs_nailbarrel01x", "p_firebarrel01x", "p_group_barrel01x_sd", "p_group_barrel05b", "p_group_barrel06x", "p_group_barrel09x", "p_group_barrelcor01", "p_group_barrelshot03", "p_grp_barrel01x_sal_sd", "p_grp_w_tra_barrelhalf01x", "p_gunbarrelset01x", "p_gunsmithbarrels01x", "p_haypilewheelbarrel01x", "p_pigbarrel01x", "p_shotgun_doublebarrel01", "p_static_barrel_01a", "p_static_barrel_01b", "p_static_barrel_02a", "p_static_barrel_02b", "p_static_barrel_03a", "p_static_barrel_03b", "p_static_barrel_04a", "p_static_barrel_04b", "p_static_barrel_05a", "p_static_barrel_05b", "p_static_barrel_06a", "p_static_barrel_07a", "p_static_barrel_08a", "p_static_barrel_09a", "p_static_barrel_cor01a", "p_static_barrel_cor01b", "p_static_barrel_cor02a", "p_static_barrel_cor02b", "p_static_barrel_cor03a", "p_static_barrel_cor03b", "p_static_barrel_cor04a", "p_static_barrel_cor04b", "p_static_barrel_cor05a", "p_static_barrel_cor05b", "p_static_barrel_cor06a", "p_static_barrelcrate01", "p_static_cratebarrel01", "p_static_w_tra_barrel01x", "p_sto_barrel01x", "p_sto_barrelsalt01x", "p_stovegasbarrel01x", "p_tmtsaucebarrel02x", "p_tmtsaucebarrels01x", "p_veh_cart03_barrels01x", "p_veh_chucksidebarrel01", "p_veh_chucksidebarrel02", "p_veh_chucksidebarrel03", "p_veh_sidebarrelsupport01x", "p_wheelbarrel01x", "p_whiskeybarrel01x", "p_winebarrel01x", "p_wood_barrel_001", "s_barrelartshop01x", "s_cvan_barrel", "s_gen_barrelhalf02x", "w_dis_sho_doublebarrel01", "mp005_s_posse_col_chair01x", "mp005_s_posse_foldingchair_01x", "mp005_s_posse_trad_chair01x", "mp007_p_mp_chairdesk01x", "mp007_p_nat_chairfolding02x", "p_ambchair01x", "p_ambchair02x", "p_armchair01x", "p_barberchair01x", "p_barberchair02x", "p_barberchair03x", "p_birthingchair01x", "p_bistrochair01x", "p_chair02x", "p_chair02x_dmg", "p_chair04x", "p_chair05x", "p_chair05x_sea", "p_chair06x", "p_chair06x_dmg", "p_chair07x", "p_chair09x", "p_chair11x", "p_chair12bx", "p_chair12x", "p_chair13x", "p_chair14x", "p_chair15x", "p_chair16x", "p_chair17x", "p_chair18x", "p_chair19x", "p_chair20x", "p_chair21_leg01x", "p_chair21x", "p_chair21x_fussar", "p_chair22x", "p_chair23x", "p_chair24x", "p_chair25x", "p_chair26x", "p_chair27x", "p_chair30x", "p_chair31x", "p_chair34x", "p_chair37x", "p_chair38x", "p_chair_10x", "p_chair_barrel04b", "p_chair_crate02x", "p_chair_crate15x", "p_chair_cs05x", "p_chair_privatedining01x", "p_chairbroken01x", "p_chaircomfy01x", "p_chaircomfy02", "p_chaircomfy03x", "p_chaircomfy04x", "p_chaircomfy05x", "p_chaircomfy06x", "p_chaircomfy07x", "p_chaircomfy08x", "p_chaircomfy09x", "p_chaircomfy10x", "p_chaircomfy11x", "p_chaircomfy12x", "p_chaircomfy14x", "p_chaircomfy16x", "p_chaircomfy17x", "p_chaircomfy18x", "p_chaircomfy22x", "p_chaircomfy23x", "p_chaircomfycombo01x", "p_chairconvoround01x", "p_chairdeck01x", "p_chairdeckfolded01x", "p_chairdesk01x", "p_chairdesk02x", "p_chairdining01x", "p_chairdining02x", "p_chairdining03x", "p_chairdoctor01x", "p_chairdoctor02x", "p_chaireagle01x", "p_chairfolding02x", "p_chairhob01x", "p_chairhob02x",
    }
    for _, model in ipairs(itemModels) do
        exports['rsg-target']:AddTargetModel(model, {
            options = {
                {
                    label = "Pick Up",
                    action = function(entity)
                        local coords = GetEntityCoords(entity)
                        DeleteEntity(entity)
                        createAndPickupObject(model, coords)
                    end,
                    canInteract = function(entity)
                        return not carryingEntity
                    end
                }
            },
            distance = 2.0
        })
    end
end)

RegisterNetEvent('redm:updateEntityCarry')
AddEventHandler('redm:updateEntityCarry', function(netId, isCarried, playerId)
    local entity = NetworkGetEntityFromNetworkId(netId)
    if DoesEntityExist(entity) then
        if isCarried then
            local carrierPed = GetPlayerPed(GetPlayerFromServerId(playerId))
            AttachEntityToEntity(entity, carrierPed, GetPedBoneIndex(carrierPed, 28422), 0.0, 0.5, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
        else
            DetachEntity(entity, true, true)
            PlaceObjectOnGroundProperly(entity)
        end
    end
end)
