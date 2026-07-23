#include <amxmodx>
#include <amxmisc>
#include <reapi>

new bool:g_bChosenOnce[33];

public plugin_precache()
{
    /*precache_model("models/player/cse_vip_ct/cse_vip_ct.mdl");
    precache_model("models/player/cse_vip_t/cse_vip_t.mdl");*/
    precache_model("models/cselites/v_knife_vip.mdl");
    //precache_model("models/cselites/p_knife_vip.mdl");
}

public plugin_init() 
{
    register_plugin("VIP System", "1.0", "DadoDz")

    register_menu("VIP Menu", MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0, "menu_vip")
    
    register_clcmd("say /vm", "cmd_open_vip_menu")
    register_clcmd("say vm", "cmd_open_vip_menu")
    register_clcmd("say_team /vm", "cmd_open_vip_menu")
    register_clcmd("say_team vm", "cmd_open_vip_menu")
    register_clcmd("nightvision", "cmd_open_vip_menu")

    register_clcmd("say /vip", "cmd_show_vip_motd")
    register_clcmd("say vip", "cmd_show_vip_motd")
    register_clcmd("say_team /vip", "cmd_show_vip_motd")
    register_clcmd("say_team vip", "cmd_show_vip_motd")

    register_logevent("OnRoundStart", 2, "1=Round_Start");

    RegisterHookChain(RG_CBasePlayer_Spawn, "fw_PlayerSpawn_Post", true)
    RegisterHookChain(RG_CBasePlayerWeapon_DefaultDeploy, "OnWeaponDeploy", true)

    set_task(90.0, "advertisement", _, _, _, "b")
}

public client_putinserver(id) 
{
    if (!is_user_connected(id))
        return

    set_task(2.0, "check_steam_vip", id)
}

public check_steam_vip(id) 
{
    if (!is_user_connected(id))
        return

    if (is_user_steam(id))
    {
        set_user_flags(id, get_user_flags(id) | VIP_FLAG)
        client_print_color(id, 0, "^x04[^1CSE^4]^x01 Real^x03 Steam^x01 detected^x04!^x01 You received^x04 FREE VIP^x01.")
    }
}

public OnRoundStart()
{
    for (new id = 1; id <= get_maxplayers(); id++)
        g_bChosenOnce[id] = false;
}

public fw_PlayerSpawn_Post(id)
{
    if (!is_user_alive(id) || !is_user_vip(id))
        return;

    //set_task(0.2, "SetVIPModel", id);
    set_task(0.2, "SetScoreAttribVIP", id);
    set_task(1.0, "show_vip_menu", id);

    if (get_member(id, m_iTeam) == TEAM_CT)
        rg_give_defusekit(id)
}

public OnWeaponDeploy(const weapon)
{
    new id = get_member(weapon, m_pPlayer)

    if (!is_user_alive(id) || !is_user_vip(id))
        return

    new weaponid = get_member(weapon, m_iId)

    if (weaponid == CSW_KNIFE)
    {
        set_pev(id, pev_viewmodel2, "models/cselites/v_knife_vip.mdl")
        //set_pev(id, pev_weaponmodel2, "models/cselites/p_knife_vip.mdl")
    }
}

/*public SetVIPModel(id)
{
    if (!is_user_alive(id) || !is_user_vip(id))
        return;

    if (get_member(id, m_iTeam) == TEAM_CT)
        rg_set_user_model(id, "cse_vip_ct")
    else
        rg_set_user_model(id, "cse_vip_t")
}*/

public SetScoreAttribVIP(id)
{
    if (!is_user_connected(id) || !is_user_alive(id) || !is_user_vip(id))
        return;

    message_begin(MSG_BROADCAST, get_user_msgid("ScoreAttrib"))
    write_byte(id)
    write_byte(4)
    message_end()
}

public cmd_open_vip_menu(id)
{
    if (!is_user_alive(id) || !is_user_vip(id) || g_bChosenOnce[id] == true)
        return PLUGIN_HANDLED;

    show_vip_menu(id);
    return PLUGIN_HANDLED;
}

public show_vip_menu(id)
{
    if (!is_user_connected(id) || !is_user_alive(id) || !is_user_vip(id) || g_bChosenOnce[id] == true)
        return;

    static menu[500], len;
    len = 0
	
    len += formatex(menu[len], charsmax(menu) - len, "\r[\yVIP Menu\r]^n^n")

    len += formatex(menu[len], charsmax(menu) - len, "\r[\y1\r]\w AK-47\d +\w Deagle^n")

    len += formatex(menu[len], charsmax(menu) - len, "\r[\y2\r]\w M4-A1\d +\w Deagle^n")

    len += formatex(menu[len], charsmax(menu) - len, "\r[\y3\r]\w AWP\d +\w Deagle^n")

    len += formatex(menu[len], charsmax(menu) - len, "^n\r[\y0\r]\w Exit")

    if (pev_valid(id) == 2)
        set_pdata_int(id, 205, 0, 5)
	
    show_menu(id, MENU_KEY_1|MENU_KEY_2|MENU_KEY_3|MENU_KEY_4|MENU_KEY_5|MENU_KEY_6|MENU_KEY_7|MENU_KEY_8|MENU_KEY_9|MENU_KEY_0, menu, -1, "VIP Menu")
}

public menu_vip(id, key)
{
    if (!is_user_connected(id) || !is_user_alive(id) || !is_user_vip(id) || g_bChosenOnce[id] == true || key == 9)
        return PLUGIN_HANDLED;

    new bool:hadDefuseKit = false
    if (get_member(id, m_iTeam) == TEAM_CT && get_member(id, m_bHasDefuser))
        hadDefuseKit = true

    new bool:hadC4 = false
    new c4 = get_member(id, m_rgpPlayerItems, 5)

    if (c4 > 0 && is_entity(c4) && get_member(c4, m_iId) == WEAPON_C4)
        hadC4 = true

    rg_remove_all_items(id)

    rg_give_item(id, "weapon_knife")
    rg_give_item(id, "weapon_hegrenade")
    rg_give_item(id, "weapon_flashbang")

    if (hadDefuseKit)
        rg_give_defusekit(id)

    if (hadC4)
    {
        rg_give_item(id, "weapon_c4")
        set_member(id, m_bHasC4, true)
    }

    rg_set_user_armor(id, 100, ARMOR_VESTHELM)

    switch (key)
    {
        case 0:
        {
            rg_give_item(id, "weapon_ak47");
            rg_set_user_bpammo(id, WEAPON_AK47, 90);
        }
        case 1:
        {
            rg_give_item(id, "weapon_m4a1");
            rg_set_user_bpammo(id, WEAPON_M4A1, 90);
        }
        case 2:
        {
            rg_give_item(id, "weapon_awp");
            rg_set_user_bpammo(id, WEAPON_AWP, 30);
        }
    }

    rg_give_item(id, "weapon_deagle");
    rg_set_user_bpammo(id, WEAPON_DEAGLE, 90);
    g_bChosenOnce[id] = true;

    return PLUGIN_HANDLED;
}

public cmd_show_vip_motd(id)
{
    show_motd(id, "vip.html", "VIP Information")
    return PLUGIN_HANDLED
}

public advertisement()
{
    //client_print_color(0, 0, "^x04[^x01CSE^x04]^x03 Steam^x01 players get ^x04FREE VIP^x01!")

    set_hudmessage(random_num(0, 225), random_num(0, 225), random_num(0, 225), -1.0, 0.25, 0, 6.0, 10.0)
    show_hudmessage(0, "Steam Players Get FREE VIP!^nJoin with Steam Now!")
}

bool:is_user_vip(id) return (get_user_flags(id) & ADMIN_LEVEL_H) != 0;
