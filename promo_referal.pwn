#if defined _promo_referal_inc
	#endinput
#endif
#define _promo_referal_inc

#define PROJECT_NAME        "Honest Role Play"
#define TABLE_PROMOCODE     "s_promo_code"
#define TABLE_PROMO_TEMP    "s_promo_progress"


enum E_PLAYER_PROMO {
    uUsed,
    //uOwnerID,
    uCodeID,
    uCurrentLevel,
    uTypeLevel
}
new gPromoCode[MAX_PLAYERS][E_PLAYER_PROMO];

new defaultPlayerPromo[E_PLAYER_PROMO] = {
	0, //uUsed,
    //0, //uOwnerID
	0, //uCodeID,
	0, //uCurrentLevel,
	1 //uTypeLevel
};
stock GetPlayerData(playerid, E_PLAYER_INFO:type) {
    return pInfo[playerid][type];
}
stock SetPlayerData(playerid, E_PLAYER_INFO:type, value) {
    pInfo[playerid][type] = value;
    return 1;
}

/* Load Account
        format(query_, sizeof query_, "SELECT * FROM "TABLE_PROMO_TEMP" WHERE `promoID` = %d LIMIT 1", pInfo[playerid][pID]);
		mysql_tquery(dbHandle, query_, "OnLoadPlayerDataPromoCode" , "i", playerid); 
*/
/*
Name Table - s_promo_progress
promoID (int) = -1
uUsed (int) = 0
uCodeID (int) = 0
uCurrentLevel (int) = 0
uTypeLevel (int) = 1
*/
/*
name table - s_promo_code

code - Name Promo (varchar)
codeOwner - Owner Promo (varchar) 
codeID - Owner ID promo (int) default -1
codeUsed - All used users (Int) default 0
codeUsed5 - first 5 level (int) default 0
codeUsed10 - first 10 Level (int) default 0 
codeDonate - Donate Coins (int) default "0"
date - create Date (unix)
*/

/*
enum {
    D_PROMO_CODE_REFERAL_0,
    D_PROMO_CODE_REFERAL_1, // return Main Menu
    D_PROMO_CODE_REFERAL_2,
    D_PROMO_CODE_REFERAL_3,
    D_PROMO_CODE_REFERAL_4,
    D_PROMO_CODE_REFERAL_5,
    D_PROMO_CODE_REFERAL_6,
    D_PROMO_CODE_REFERAL_7,
    D_PROMO_CODE_REFERAL_8,
    D_PROMO_CODE_REFERAL_9,
    D_PROMO_CODE_REFERAL_10

}*/
CMD:test(playerid) {
    showPlayerDialogPromoReferal(playerid);
    return 1;
}
showPlayerDialogPromoReferal(playerid) {
    format(t_string, sizeof t_string, 
        ""colwhi"[0] ��� ����� ��������?\n\
        [1] ������� �������� / ����� / ������� / ������������� ��� �� ������\n\
        [2] ������� �������� (���������)\n\
        [3] ������� ��������\t"collime"$10.000.000\n\
        [4] ��������� �������� � �����\n\
        [5] ������ ��������� ��� ���������\n\
        "colwhi"[6] "col_li_red"������� ��������\n\
        "colwhi"[-] ����������� ����������"
    );
    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_0, DIALOG_STYLE_LIST, ""colserver"����������: "colwhi"����������", t_string, "�������", "�����"), t_string[0] = EOS;
    return 1;
} 

PromoCode:getPlayerPromoDonate(promoid) {
    new
        query_[64];
    format(query_, sizeof query_, "SELECT codeDonate FROM "TABLE_PROMOCODE" WHERE codeID = '%d' LIMIT 1", promoid);
    new
        Cache: result = mysql_query(dbHandle, query_), coins_count = 0;
    cache_get_value_int(0, "codeDonate", coins_count);
    if (cache_is_valid(result)) cache_delete(result);
    return coins_count;

}
PromoCode:getPlayerPromoCreateDate(promoid) {
    new
        query_[64];
    format(query_, sizeof query_, "SELECT date FROM "TABLE_PROMOCODE" WHERE codeID = '%d' LIMIT 1", promoid);
    new
        Cache: result = mysql_query(dbHandle, query_), date_create[32]; 
    date_create = "01.01.2021";
    cache_get_value_name(0, "date", date_create);
    if (cache_is_valid(result)) cache_delete(result);
    return date_create;
}
PromoCode:getPlayerPromoAllUsed(promoid) {
    new
        query_[64];
    format(query_, sizeof query_, "SELECT codeUsed FROM "TABLE_PROMOCODE" WHERE codeID = '%d' LIMIT 1", promoid);
    new
        Cache: result = mysql_query(dbHandle, query_), count_used = 0; 
    cache_get_value_int(0, "codeUsed", count_used);
    if (cache_is_valid(result)) cache_delete(result);
    return count_used;
}
PromoCode:getPlayerPromoName(promoid) {
	new 
        query_[84];
	format(query_, sizeof query_,"SELECT * FROM "TABLE_PROMOCODE" WHERE codeID = '%d' LIMIT 1", promoid);
	new Cache: result = mysql_query(dbHandle, query_); 
	new 
		value = cache_num_rows(),
		promo_name[32];
	if (!value) {
		promo_name = "None";
	} else {
		cache_get_value_name(0, "code", promo_name);
	} 
	if (cache_is_valid(result)) cache_delete(result);
	return promo_name;
}
PromoCode:GetPlayerSearch(playerid) {
    new
        bool: isReturn = false,
        query_[64];
    format(query_, sizeof query_, "SELECT * FROM "TABLE_PROMOCODE" WHERE codeID = '%d' LIMIT 1",  GetPlayerData(playerid, pID));
    new 
        Cache:result = mysql_query (dbHandle, query_), rows; 
    cache_get_row_count(rows); 
    if (rows) {
       // if (cache_is_valid(result)) cache_delete(result);
        isReturn = true;
    }
    if (cache_is_valid(result)) cache_delete(result);
    return isReturn;
}
forward IsPromoCodeCreate(playerid, promo[]);
public IsPromoCodeCreate(playerid, promo[]) {
    if (kLibGetPlayerMoney(playerid) < 10_000_000) return SendClientMessage(playerid, COLOR_WHITE, !"� ��� ��� ������� �����");
    kLibGivePlayerMoney(playerid, -10_000_000, "���������� �����");
    new
        rows;
    cache_get_row_count(rows);
    if (rows) {
        SendClientMessage(playerid, COLOR_GREY, !"������ �������� ��� ���� � ������");
        return 0;
    }
    new 
        query_[128];
    mysql_format(dbHandle, query_, sizeof query_, "INSERT INTO "TABLE_PROMOCODE" (code, codeOwner, codeID, date) VALUES ('%s', '%s', '%d', NOW())", 
        promo,
        GetPlayerData(playerid, pName),
        GetPlayerData(playerid, pID)
    );
    mysql_tquery(dbHandle, query_, "", "");
    format(query_, sizeof query_, "��� �������� %s | �������� �������� F8", promo);
    SendClientMessage(playerid, COLOR_WHITE, query_), query_[0] = EOS; 
    return 1;
} 
#define DEFAULT_ALPHABET "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
GenerateRandomString(result_str[], length, const size = sizeof(result_str), const alphabet[] = DEFAULT_ALPHABET, const alphabet_size = sizeof(alphabet))
{
    result_str[0] = '\0'; 
    if (length >= size) length = size - 1;  
    for (new i = 0; i < length; i++)  result_str[i] = alphabet[ random(alphabet_size - 1) ]; 
    return 1;
} 
Promo_OnDialogResponse(playerid, dialogid, response, listitem, const inputtext[]) { 
	switch (dialogid) {
        case D_PROMO_CODE_REFERAL_0: {
            if (!response) {
                return 1; // TODO: return MainMenu
            }
            switch(listitem) {
                case 0: {
                    static const info_referals[] = ""colwhi"��� ����� ��������?\n\
                        ��� ����������� ���������� ���, ������� �� ������ ������� � ���� ��� ������ �����\n\
                        ��������� ��� ������ �������� �������� ������������ ������ �� "colserver##PROJECT_NAME##colwhi"!\n\
                        �� ��� � ������� � �� � �� �������� ������� ������\n\n\
                        ��� ���� ��������?\n\
                        ���� ���-�� ������ ��� �������� ��� ����������� (��� �����) �� ����� 5 �������\n\
                        �� � ��� ����� �������� �� "collime"$150.000"colwhi", � ����� ��� ����� 5 ������� �� � �� �������� �� "collime"$300.000\n\n\
                        "colwhi"���� ����� ������ ��������?\n\
                        ���� �������� �� ������ ������ ����� ����� � ������������ ���������\n\
                        � � ������ ���������� � ���������� �����, � ������������ ��� � �������� ����� ��� �������\n";
                    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_1, DIALOG_STYLE_MSGBOX, ""colserver"����������", info_referals, "�����", "");
                }
                case 1: { //[1] ������� ����� / ������� / ������������� ��� �� ������\n
                    if (GetPlayerData(playerid, pLevel) > 5) return SendClientMessage(playerid, COLOR_ORANGE, "� ��� ������� ������� ������� ����� ������� �������������");
                    if (PromoCode:GetPlayerData(playerid, uUsed) == 1 || PromoCode:GetPlayerSearch(playerid)) {
                        SendClientMessage(playerid, COLOR_GREY, "� ��� ����������� ��� ��������, ��� ������ ����");
                        return 1;
                    }
				    format(t_string, sizeof t_string, "\n"colwhi"������� ��������, ������� ������ ������������\n"); 
					ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_4, DIALOG_STYLE_INPUT, "��������", t_string, "�����", "�����"), t_string[0] = EOS;
                }
                case 2: { //[2] ������� �������� (���������)\n
                    if (GetPlayerData(playerid, pLevel) < 5) return SendClientMessage(playerid, COLOR_GREY, !"�������� ����� ������� ����� 5-�� ������");
                    if (PromoCode:GetPlayerSearch(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, !"� ��� ��� ���� ��������. ������� ��������, ����� ������� �����");
                    new 
                        code_[8],
                        query_[128];
                    GenerateRandomString(code_, 6);
                    mysql_format(dbHandle, query_, sizeof query_, "INSERT INTO "TABLE_PROMOCODE" (code, codeOwner, codeID) VALUES ('%s', '%s', '%d')", 
                        code_, pInfo[playerid][pName], GetPlayerData(playerid, pID)
                    );
	                mysql_tquery(dbHandle, query_, "", ""); 
                    format(query_, sizeof query_, "[���������] "colwhi"��� ��������: "colrose"%s"colwhi" | �������� �������� F8", code_);
                    SendClientMessage(playerid, COLOR_YELLOW, query_), query_[0] = EOS;
                }
                case 3: { //[3] ������� ��������\n V
                    if (!PromoCode:GetPlayerSearch(playerid)) return SendClientMessage(playerid, COLOR_ORANGE, !"� ��� ��� ���������, ���������� ������� ������� ��������");
                    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_2, DIALOG_STYLE_INPUT, ""colserver"��������: "colwhi"����� ���������",
                        ""colwhi"�� ������ ������� ���� ������ ��������, ������� ����� ����������\n\
                        ��������� �������: ��������� ����. ����� � �����\n\n\
                        ���� ���������: "collime"$10.000.000", "�������", "�����"
                    );
                }
                case 4: {
                    if (!PromoCode:GetPlayerSearch(playerid)) return SendClientMessage(playerid, COLOR_GREY, !"� ��� ��� ���������");
                    if (GetPlayerData(playerid, pFamily) == 0) return SendClientMessage(playerid, COLOR_GREY, !"�� �� �������� � �����");
                    if (!GetString(FamilyInfo[ pInfo[playerid][pFamily] - 1 ][fOwner], pInfo[playerid][pName])) return SendClientMessage(playerid, COLOR_GREY, !"�� �� ���������� �����");
                    new 
                        family_id = pInfo[playerid][pFamily] - 1;
                    if (Family:GetFamilyData(family_id, fPromoID) != -1) return SendClientMessage(playerid, COLOR_GREY, !"�������� ��� �������� � �����");
                    FamilyInfo[family_id][fPromoID] = GetPlayerData(playerid, pID); 
                    new
                        query_[128];
                    format( query_, sizeof query_, "UPDATE `s_family` SET `fPromoID` = '%d' WHERE `fID` = '%d' LIMIT 1",
                        Family:GetFamilyData(family_id, fPromoID), GetPlayerData(playerid, pFamily)
                    );
                    mysql_tquery(dbHandle, query_, "", ""), query_[0] = EOS;
                    format(query_, sizeof query_, "�� ������� ��������� �������� � ����� {%s}%s", 
                        family_chat_color[ FamilyInfo[ family_id ][fChatColor] ], FamilyInfo[ family_id ][fName]
                    );
                    SendClientMessage(playerid, COLOR_WHITE, query_), query_[0] = EOS;
                } 
                case 5: {
                    if (!PromoCode:GetPlayerSearch(playerid)) return SendClientMessage(playerid, COLOR_GREY, !"� ��� ��� ���������");
                    PromoCode:showAccesoryPromoBuyMenu(playerid);
                }
                case 6: { //[5] ������� ��������\n V
                    if (!PromoCode:GetPlayerSearch(playerid)) return SendClientMessage(playerid, COLOR_GREY, !"� ��� ��� ���������");
                    format(t_string, sizeof t_string, 
                        ""colwhi"�� ������ ������� ���� ��������: "collime"%s\n\
                        "col_li_red"��������! ���� �� ������� ��������\n\
                        �� ��� ����������� �� ��� ��������, �������� � ������� ������ �� ���� ��������, ������\n\n\
                        "colwhi"�� ������������� ������ ������� ���� ��������?", PromoCode:getPlayerPromoName(GetPlayerData(playerid, pID))
                    ); 
                    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_3, DIALOG_STYLE_MSGBOX, ""colserver"��������: "colwhi"��������", t_string, "�������", "�����"), t_string[0] = EOS;
                } 
                case 7: { // V
                    if (!PromoCode:GetPlayerSearch(playerid)) return SendClientMessage(playerid, COLOR_GREY, !"� ��� ��� ���������");
                    format(t_string, sizeof t_string, 
                        "\n"colwhi"��� ��������:\t\t\t%s\n\
                        ���������� �������������:\t\t%d �������\n\
                        ���� ��������:\t\t\t\t%s\n\n\
                        �������� �����:\t\t\t"collime"%d H-Point", 
                        PromoCode:getPlayerPromoName(GetPlayerData(playerid, pID)),
                        PromoCode:getPlayerPromoAllUsed(GetPlayerData(playerid, pID)),
                        PromoCode:getPlayerPromoCreateDate(GetPlayerData(playerid, pID)),
                        PromoCode:getPlayerPromoDonate(GetPlayerData(playerid, pID))
                    );
                    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_1 , DIALOG_STYLE_MSGBOX, ""colserver"��������: "colwhi"����������� ����������", t_string, "�������", ""), t_string[0] = EOS;
                }
            }
            return 1;
        }
        case D_PROMO_CODE_REFERAL_1: {
            if (!response) {
                return 1;
            }
            showPlayerDialogPromoReferal(playerid);
            return 1;
        }
        case D_PROMO_CODE_REFERAL_2: {
            if (!response) {
                return 1;
            }
            if (kLibGetPlayerMoney(playerid) < 10_000_000) return SendClientMessage(playerid, COLOR_GREY, !"� ��� ��� ������� �����");
            if (!strlen(inputtext)) {
                ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_2, DIALOG_STYLE_INPUT, ""colserver"��������: "colwhi"����� ���������",
                    ""colwhi"�� ������ ������� ���� ������ ��������, ������� ����� ����������\n\
                    ��������� �������: ��������� ����. ����� � �����\n\n\
                    ���� ���������: "collime"$10.000.000", "�������", "�����"
                );
            }
            if (is_text_invalid(inputtext)) {
                ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_2, DIALOG_STYLE_INPUT, ""colserver"��������: "colwhi"����� ���������",
                    ""colwhi"�� ������ ������� ���� ������ ��������, ������� ����� ����������\n\
                    ��������� �������: ��������� ����. ����� � �����\n\n\
                    ���� ���������: "collime"$10.000.000", "�������", "�����"
                );
                return 1;
            }
            for (new i = strlen(inputtext); i != 0; --i)
			{
				switch(inputtext[i]) {
					case '�'..'�', '�'..'�', ' ': {
					    SendClientMessage(playerid, COLOR_GREY, !"������ ��������� ��������� �� ������� ���������");
						return ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_2, DIALOG_STYLE_INPUT, ""colserver"��������: "colwhi"����� ���������",
                            ""colwhi"�� ������ ������� ���� ������ ��������, ������� ����� ����������\n\
                            ��������� �������: ��������� ����. ����� � �����\n\n\
                            ���� ���������: "collime"$10.000.000", "�������", "�����"
                        );
					}
				}
			}
			if (!(3 <= strlen(inputtext) <= 16)) {
			    SendClientMessage(playerid, COLOR_GREY, !"����������� �� 3 �� 16 ��������");
				return ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_2, DIALOG_STYLE_INPUT, ""colserver"��������: "colwhi"����� ���������",
                    ""colwhi"�� ������ ������� ���� ������ ��������, ������� ����� ����������\n\
                    ��������� �������: ��������� ����. ����� � �����\n\n\
                    ���� ���������: "collime"$10.000.000", "�������", "�����"
                );
            }
            if (kLibGetPlayerMoney(playerid) < 10_000_000) return SendClientMessage(playerid, COLOR_WHITE, !"� ��� ��� ������� �����");
            kLibGivePlayerMoney(playerid, -10_000_000, "���������� �����");
            format(t_string, sizeof t_string, "[�����������] "colwhi"������ ��� ��������: %s", inputtext);
            SendClientMessage(playerid, COLOR_LI_RED, t_string), t_string[0] = EOS;
            new 
                query_[128];
            mysql_format(dbHandle, query_, sizeof query_, 
                "UPDATE "TABLE_PROMOCODE" SET code = '%s' WHERE codeID = '%d'", 
                inputtext,
                GetPlayerData(playerid, pID)
            );
            mysql_tquery(dbHandle, query_, "", "");   
            return 1;
        }
        case D_PROMO_CODE_REFERAL_3: { // Delete Promo code owner ID
            if (!response) {
                showPlayerDialogPromoReferal(playerid);
                return 1;
            }
            new 
                promo_ID = GetPlayerData(playerid, pID),
                query_[128];
            mysql_format(dbHandle, query_, sizeof query_, "DELETE FROM "TABLE_PROMOCODE" WHERE codeID = '%d'", promo_ID);
            mysql_tquery(dbHandle, query_, "", ""), query_[0] = EOS; 
            foreach(new i: PlayerInLogin) {
                if (PromoCode:GetPlayerData(i, uCodeID) == promo_ID) {
                    gPromoCode[i] = defaultPlayerPromo;
                    SendClientMessage(i, COLOR_LI_RED, !"[�����������] "colwhi"�������� ������� ��� ���� ����������� ��� ������"); 
                }
            } 
            PromoCode:ClearPlayerPromoCode(promo_ID);
            return 1;
        }
        case D_PROMO_CODE_REFERAL_4: {
            if (!response) {
                showPlayerDialogPromoReferal(playerid);
                return 1; 
            }
            new 
                query_[128];
            format(query_, sizeof query_, "SELECT `codeID`, `code` FROM "TABLE_PROMOCODE" WHERE code LIKE '%s'", inputtext);
			new Cache: tempQuery = mysql_query(dbHandle, query_), rows;
			cache_get_row_count(rows);
			if (!rows) {
				print(!"[�������� ...] ������ �� "TABLE_PROMOCODE" �� ��������!");
				SendClientMessage(playerid, COLOR_GREY, !"��������� �������� �� ������");
				if (cache_is_valid(tempQuery)) cache_delete(tempQuery);
				return 1;
			}
	        if (PromoCode:GetPlayerData(playerid, uUsed)) return SendClientMessage(playerid, COLOR_GREY, !"�� ����� �������� ��� ����������� ��������!");
            new
                codeid;
            cache_get_value_name_int(0, "codeID", codeid);
            PromoCode:SetPlayerData(playerid, uUsed, 1, .save = false);
            PromoCode:SetPlayerData(playerid, uTypeLevel, 1, .save = false);
            PromoCode:SetPlayerData(playerid, uCurrentLevel, (GetPlayerData(playerid, pLevel) + 5), .save = false);
            PromoCode:SetPlayerData(playerid, uCodeID, codeid, .save = false);
            mysql_format(dbHandle, query_, sizeof query_, 
                "UPDATE "TABLE_PROMO_TEMP" SET uUsed = '%d', uCurrentLevel = '%d', uTypeLevel = '%d', uCodeID = '%d' WHERE promoID = '%d'", 
                gPromoCode[playerid][uUsed], gPromoCode[playerid][uCurrentLevel], gPromoCode[playerid][uTypeLevel],
                gPromoCode[playerid][uCodeID], GetPlayerData(playerid, pID)
            );
            mysql_tquery(dbHandle, query_, "", "");  
            mysql_format(dbHandle, query_, sizeof query_, 
                "UPDATE "TABLE_PROMOCODE" SET codeUsed = codeUsed+1 WHERE codeID = '%d'", 
                codeid
            );

            mysql_tquery(dbHandle, query_, "", "");  
			if (cache_is_valid(tempQuery)) cache_delete(tempQuery); 
            format(query_, sizeof query_, "[�����������] "colwhi"�� ������������ �������� %s, ������ ������� �� �������� �� %d ������", 
                inputtext,
                PromoCode:GetPlayerData(playerid, uCurrentLevel)
            );
            SendClientMessage(playerid, COLOR_GREEN, query_), query_[0] = EOS;
            return 1;
        }
        case D_PROMO_CODE_REFERAL_5: {
            if (!response) {
                return 1;
            }
            switch (listitem) {
                case 0: {
                    showPlayerPromoCodeList(playerid);
                }
                case 1: {
                    format(t_string, sizeof t_string, "\n������� ��������, ������� ������ �����\n"); 
					ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_7, DIALOG_STYLE_INPUT, "��������", t_string, "�����", "�����"), t_string[0] = EOS;
                }
                case 2: {
                    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_9, DIALOG_STYLE_INPUT, 
                        "�������� ���������: ��������", 
                        "������� �������� ��������� ������� ������ �������\n������ ��� ������������ � ������ [code, name, id account]:\n\t#mickey,Mickey_Waerd,1", 
                        "�����", "�����"
                    );
                }
                case 3: {
                    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_10, DIALOG_STYLE_INPUT, 
                        ""colserver"������� ����������: "colwhi"�������� ���������", 
                        ""colwhi"������� �������� ������� ������ �������", "�����", "�����"
                    );
                }
            }
            return 1;
        }
        case D_PROMO_CODE_REFERAL_6: {
			if (!response) {
				showPlayerDialogAdminPromo(playerid);
				return 1;
			}
			new 
				page = pTemp[playerid][tSelectPage],
				id = playerListItem[playerid][listitem];

			switch (id) {
				case 1: showPlayerPromoCodeList(playerid, page + 1);
				case 2: showPlayerPromoCodeList(playerid, page - 1);
				default: showPlayerPromoCodeList(playerid, page);
			} 
			return 1;
		} 
        case D_PROMO_CODE_REFERAL_7: {
            if (!response) {
                showPlayerDialogAdminPromo(playerid);
                return 1;
            }
            new 
                query_[128];
            format(query_, sizeof query_, "SELECT `codeID` FROM "TABLE_PROMOCODE" WHERE code LIKE '%s'", inputtext);
			new Cache: tempQuery = mysql_query(dbHandle, query_), rows;
			cache_get_row_count(rows);
			if (!rows) {
				print(!"[�������� ...] ������ �� "TABLE_PROMOCODE" �� ��������!");
				SendClientMessage(playerid, COLOR_GREY, !"��������� �������� �� ������");
				if (cache_is_valid(tempQuery)) cache_delete(tempQuery);
				return 1;
			}
            new
                codeid;
            cache_get_value_name_int(0, "codeID", codeid);
            if (cache_is_valid(tempQuery)) cache_delete(tempQuery); 
            format(t_string, sizeof t_string, 
                "\n��� ��������:\t\t\t%s\n\
                ���������� �������������:\t\t%d �������\n\
                ���� ��������:\t\t\t\t%s\n\n\
                �������� �����:\t\t\t%d ������", 
                PromoCode:getPlayerPromoName(codeid),
                PromoCode:getPlayerPromoAllUsed(codeid),
                PromoCode:getPlayerPromoCreateDate(codeid),
                PromoCode:getPlayerPromoDonate(codeid)
            );
            ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_8, DIALOG_STYLE_MSGBOX, "���������� ���������", t_string, "�����", "�������"), t_string[0] = EOS;	
            return 1;
        }
        case D_PROMO_CODE_REFERAL_8: {
            if (!response) {
                return 1;
            }
            showPlayerDialogAdminPromo(playerid);
            return 1;
        }
        case D_PROMO_CODE_REFERAL_9: {
            if (!response) {
                showPlayerPromoCodeList(playerid);
                return 1;
            }
            new
                name_code[16], name_owner[MAX_PLAYER_NAME], owner_id;
            if (sscanf(inputtext, "p<,>s[16]s[24]i", name_code, name_owner, owner_id) || !(3 <= strlen(name_code) < 16) || !(3 <= strlen(name_owner) < 24) || !(1 <= owner_id <= 10_000_000)) {
                ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_9, DIALOG_STYLE_INPUT, 
                    "�������� ���������: ��������", 
                    "������� �������� ��������� ������� ������ �������\n������ ��� ������������ � ������ [code, name, id account]:\n\t#mickey,Mickey_Waerd,1", 
                    "�����", "�����"
                );
            } 
            for(new i = strlen(name_code); i != 0; --i) {
				switch(name_code[i]) {
					case '�'..'�', '�'..'�', ' ': {
					    SendClientMessage(playerid, COLOR_GREY, !"������ ��������� ��������� �� ������� ���������");
                        ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_9, DIALOG_STYLE_INPUT, 
                            "�������� ���������: ��������", 
                            "������� �������� ��������� ������� ������ �������\n������ ��� ������������ � ������ [code, name, id account]:\n\t#mickey,Mickey_Waerd,1", 
                            "�����", "�����"
                        );
					}
				}
			} 
            new  
                query_[128]; 
            mysql_format(dbHandle, query_, sizeof query_, "INSERT INTO "TABLE_PROMOCODE" (code, codeOwner, codeID) VALUES ('%s', '%s', '%d')", 
                name_code, name_owner, owner_id
            );
            mysql_tquery(dbHandle, query_, "", ""); 
            format(query_, sizeof query_, "�� ������� �������� %s | ��������: %s [ID DB: %d]", name_code, name_owner, owner_id);
            SendClientMessage(playerid, COLOR_WHITE, query_), query_[0] = EOS;
            return 1;
        }
        case D_PROMO_CODE_REFERAL_10: {
            if (!response) {
                showPlayerDialogAdminPromo(playerid);
                return 1; 
            }
            if (!strlen(inputtext)) {
                ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_10, DIALOG_STYLE_INPUT, 
                    ""colserver"������� ����������: "colwhi"�������� ���������", 
                    ""colwhi"������� �������� ������� ������ �������", "�����", "�����"
                );
                return 1;
            }

            for(new i = strlen(inputtext); i != 0; --i)
			{
				switch(inputtext[i])
				{
					case '�'..'�', '�'..'�', ' ':
					{
					    SendClientMessage(playerid, COLOR_GREY, !"�� ������� �������� �� ������� ���������");
                        ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_10, DIALOG_STYLE_INPUT, 
                            ""colserver"������� ����������: "colwhi"�������� ���������", 
                            ""colwhi"������� �������� ������� ������ �������", "�����", "�����"
                        );
					}
				}
			}
			mysql_tquery(dbHandle, "SELECT codeID, codeOwner FROM "TABLE_PROMOCODE"", "getRemovePromoCode", "is", playerid, inputtext);
            return 1;
        }
        case D_PROMO_CODE_REFERAL_11: {
            if(!response) {
                ClearPlayerListitem(playerid); 
                return 1;
            }
            new index = GetPlayerListitem(playerid, listitem);
            switch(index) {
                case PAGE_VALUE_NEXT: {
                    SetPlayerPage(playerid, GetPlayerPage(playerid) + 1);
                    PromoCode:showAccesoryPromoBuyMenu(playerid, .type = TYPE_ITEMS_COMMON);
                }
                case PAGE_VALUE_BACK: {
                    PromoCode:showAccesoryPromoBuyMenu(playerid, .type = TYPE_ITEMS_COMMON);
                }
                default:
                {
                    ClearPlayerListitem(playerid);
                    SetPlayerRows(playerid, index);

                    SendClientMessage(playerid, -1, "debug >> page index default");
                }
            }
            return 1;
        }
    }
    return false;
} 
CMD:setpromoedit(playerid) {
    // return Amdin
    showPlayerDialogAdminPromo(playerid);
}

showPlayerDialogAdminPromo(playerid) {
    format(t_string, sizeof t_string, 
        "[0] ������ ����������\n\
        [1] ����� ��������\n\
        [2] ������� ��������\n\
        [3] ������� ��������"
    );
    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_5, DIALOG_STYLE_LIST, ""colserver"����������: "colwhi"�����������", t_string, "�������", "�������"), t_string[0] = EOS;
}
stock showPlayerPromoCodeList(playerid, page = 1) { 
    new rows, Cache:tempQuery = mysql_query(dbHandle, "SELECT * FROM "TABLE_PROMOCODE" ORDER BY `codeUsed` DESC");
    cache_get_row_count(rows);
    t_string[0] = EOS;
    
    if (!rows) {
        SendClientMessage(playerid, COLOR_GREY, !"� ������ ������ ��� ����������");
		showPlayerDialogAdminPromo(playerid);
        if (cache_is_valid(tempQuery)) cache_delete(tempQuery);
        return 1;
    }
    new max_page = (MAX_DIALOG_LIST_ITEMS + rows) / MAX_DIALOG_LIST_ITEMS, idx = 0;
    if (page < 1) page = 1;
    else if (page > max_page) page = max_page;  
    t_string = ""colserver"[�] ��������\t"colserver"���������\n"colwhi"";
    for (new i = ((page - 1) * MAX_DIALOG_LIST_ITEMS), tempName[32], tempLevel; i < (page * MAX_DIALOG_LIST_ITEMS); i++) {
        if (i >= rows) continue;
        cache_get_value_name(i, "code", tempName, sizeof (tempName));
        cache_get_value_name_int(i, "codeUsed", tempLevel); 

        format(t_string, sizeof (t_string), "%s[%i] %s\t%d ���\n", t_string, (page - 1) * MAX_DIALOG_LIST_ITEMS + idx, tempName, tempLevel);
        playerListItem[playerid][idx++] = -1;
    }
    if (page > 1) {
        strcat(t_string, "[<<<] ���������� ��������\n");
        playerListItem[playerid][idx++] = 2; // (-)
    }
    if (page < max_page) {
        strcat(t_string, "��������� �������� [>>>] \n");
        playerListItem[playerid][idx++] = 1; // (+)
    }
    pTemp[playerid][tSelectPage] = page; 

    new titleSTR[46];
    format(titleSTR, sizeof titleSTR, ""colserver"������ ���������� (�����: %d)", rows);
    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_6, DIALOG_STYLE_TABLIST_HEADERS, titleSTR, t_string, "�������", "�������"), t_string[0] = EOS;

    if (cache_is_valid(tempQuery)) cache_delete(tempQuery); 
    return 1;
}
forward getRemovePromoCode(playerid, code[]);
public getRemovePromoCode(playerid, code[])
{
	new
		rows,
		query_[128];
	cache_get_row_count(rows);
    if (!rows) {
        showPlayerDialogAdminPromo(playerid);
        SendClientMessage(playerid, COLOR_WHITE, !"��������� �������� �� ������");
        return 1;
    }
    new
        ownerID,
        ownerName[MAX_PLAYER_NAME];
    cache_get_value_name_int(0, "codeID", ownerID);
    cache_get_value_name(0, "codeOwner", ownerName);
    format(query_, sizeof query_, "�������� {FFFF00}%s{FFFFFF} ������� ����� | ID DB: %d | Owner: %s", code, ownerID, ownerName);
    SendClientMessage(playerid, COLOR_WHITE, query_);
    mysql_format(dbHandle, query_, sizeof query_, "DELETE FROM "TABLE_PROMOCODE" WHERE code = '%s'", code);
    mysql_tquery(dbHandle, query_, "", ""); 
    foreach(new i: PlayerInLogin) {
        if (PromoCode:GetPlayerData(i, uCodeID) == ownerID) {
            gPromoCode[i] = defaultPlayerPromo;
            SendClientMessage(i, COLOR_WHITE, !"�������� ������� ��� ���� ����������� ��� ������");
            SendClientMessage(i, COLOR_WHITE, !"���� �� �� �������� 5-�� ������, ����������� ������ ��������");
        }
    } 
    PromoCode:ClearPlayerPromoCode(ownerID);
	return 1;
}
CMD:info_promo(playerid) {
    SendMes(playerid, -1, "uUsed: %d", gPromoCode[playerid][uUsed]);
    SendMes(playerid, -1, "uCodeID: %d", gPromoCode[playerid][uCodeID]);
    SendMes(playerid, -1, "uCurrentLevel: %d", gPromoCode[playerid][uCurrentLevel]);
    SendMes(playerid, -1, "uTypeLevel: %d", gPromoCode[playerid][uTypeLevel]);
    return 1;
}

publics: OnLoadPlayerDataPromoCode(playerid) {
	new
		rows;
	cache_get_row_count(rows);
	if (!rows) {

		new 
			query_[128];
		format(query_, sizeof query_, "INSERT INTO "TABLE_PROMO_TEMP" (`promoID`) VALUES ('%d')", GetPlayerData(playerid, pID));
		mysql_tquery(dbHandle, query_);  
	}
	else { 
		cache_get_value_name_int(0, "uUsed", gPromoCode[playerid][uUsed]); /* default = 0 - 1 */ 
		cache_get_value_name_int(0, "uCodeID", gPromoCode[playerid][uCodeID]); /* default = 0 - ID*/
		cache_get_value_name_int(0, "uCurrentLevel", gPromoCode[playerid][uCurrentLevel]); /* �������� ��� ��������� ������� */
		cache_get_value_name_int(0, "uTypeLevel", gPromoCode[playerid][uTypeLevel]); /* default = 1*/
	}
	return 1;
}
PromoCode:CheckingForPromoCodePlayer(playerid) {
    SendClientMessage(playerid, -1,"debug >> payday >> level ++ >> checking promo");
    if (PromoCode:GetPlayerData(playerid, uUsed) != 0) {
        SendClientMessage(playerid, -1,"debug >> payday >> level ++ >> checking promo >> data used >> ");
        if (PromoCode:GetPlayerData(playerid, uTypeLevel) == 1 && (PromoCode:GetPlayerData(playerid, uCurrentLevel) == pInfo[playerid][pLevel])) {
            PromoCode:GiveUsedPromoCode(PromoCode:GetPlayerData(playerid, uCodeID), .type = 1);
            PromoCode:SetPlayerData(playerid, uTypeLevel, 2, .save = true);
            PromoCode:SetPlayerData(playerid, uCurrentLevel, GetPlayerData(playerid, pLevel) + 5, .save = true);
            pInfo[playerid][pBank] += 150_000; 
            SendClientMessage(playerid, -1,"debug >> payday >> level ++ >> checking promo >> data used >> args succ");
            PromoCode:SetGiveReferalMoney(playerid, 150_000);
            new 
                query_[128];
            format(query_, sizeof query_, "ref sys >> next current level %d", PromoCode:GetPlayerData(playerid, uCurrentLevel));
            SendClientMessage(playerid, -1, query_);
            LogMoney(playerid, 150_000, "�� ��������");
            SendClientMessage(playerid, COLOR_WHITE, !"�� �������� "collime"$150.000 "colwhi"�� ��������� ���������!"); 
        }
        if (PromoCode:GetPlayerData(playerid, uTypeLevel) == 2 && (PromoCode:GetPlayerData(playerid, uCurrentLevel) == pInfo[playerid][pLevel])) {
            PromoCode:GiveUsedPromoCode(PromoCode:GetPlayerData(playerid, uCodeID), .type = 2);
            pInfo[playerid][pBank] += 300_000; 
            PromoCode:SetGiveReferalMoney(playerid, 300_000);
            LogMoney(playerid, 300_000, "�� ��������");
            SendClientMessage(playerid, COLOR_WHITE, !"�� �������� "collime"$300.000 "colwhi"�� ��������� ���������!"); 
        }
    }
}
PromoCode:ClearPlayerPromoCode(promoid) {
    new 
        query_[128];
    mysql_format(dbHandle, query_, sizeof query_, 
        "UPDATE "TABLE_PROMO_TEMP" SET uUsed = '0', uCodeID = '0', uCurrentLevel = '0', uTypeLevel = '1' WHERE uCodeID = '%d'", 
        promoid
    );
    mysql_tquery(dbHandle, query_, "", "");  
    return 1;
}
/*PromoCode:ClearOfflinePromoCode(promoid) {
    return 1;
}*/
PromoCode:GetPlayerData(playerid, E_PLAYER_PROMO:type) {
    return gPromoCode[playerid][type];
}
PromoCode:SetPlayerData(playerid, E_PLAYER_PROMO:type, value, bool:save = false) {
    gPromoCode[playerid][type] = value;
    if (save) {
        new 
            query_[128];
        mysql_format(dbHandle, query_, sizeof query_, 
            "UPDATE "TABLE_PROMO_TEMP" SET uUsed = '%d', uCurrentLevel = '%d', uTypeLevel = '%d', uCodeID = '%d' WHERE promoID = '%d'", 
            gPromoCode[playerid][uUsed], gPromoCode[playerid][uCurrentLevel], gPromoCode[playerid][uTypeLevel],
            gPromoCode[playerid][uCodeID], GetPlayerData(playerid, pID)
        );
        mysql_tquery(dbHandle, query_, "", "");  
    }
    return 1;
} 
PromoCode:OnPlayerConnect(playerid) {
    gPromoCode[playerid] = defaultPlayerPromo;
    return 1; 
}
PromoCode:SetGiveReferalMoney(playerid, money) {
    new
        referalid = INVALID_PLAYER_ID,
        query_[128];
    foreach(new i: PlayerInLogin) {
        if (pInfo[i][pID] != PromoCode:GetPlayerData(playerid, uCodeID)) continue;  
        referalid = i;
        break; 
    }
    if (referalid != INVALID_PLAYER_ID) {
        pInfo[referalid][pBank] += money;
        LogMoney(referalid, money, "promo ref");
        SavePlayerInteger(referalid, "pBank", pInfo[referalid][pBank]);
        format(query_, sizeof query_, "�� �������� �� ����������� �� ��������� %s. +$%d �� ���������� ����!",
            pInfo[playerid][pName], money
        );
        SendClientMessage(referalid, COLOR_GREEN, query_), query_[0] = EOS;
        return 1;
    }
    mysql_format(dbHandle, query_, sizeof query_, "UPDATE `s_users` SET `pBank` = `pBank`+%d WHERE `pID` = '%d' LIMIT 1",
        money, PromoCode:GetPlayerData(playerid, uCodeID)
    );
    mysql_tquery(dbHandle, query_, "", "");
    return 1; 
}
PromoCode:GiveUsedPromoCode(promo_id, type = 1) {
    new 
        query_[128];
    if (type == 1) {
        mysql_format(dbHandle, query_, sizeof query_, 
            "UPDATE "TABLE_PROMOCODE" SET codeUsed5 = codeUsed5+1 WHERE codeID = '%d'", 
            promo_id
        );
    }
    else if (type == 2) {
        mysql_format(dbHandle, query_, sizeof query_, 
            "UPDATE "TABLE_PROMOCODE" SET codeUsed10 = codeUsed10+1 WHERE codeID = '%d'", 
            promo_id
        );
    }
    mysql_tquery(dbHandle, query_, "", ""), query_[0] = EOS;
    return 1;
}


PromoCode:showAccesoryPromoBuyMenu(playerid, type = TYPE_ITEMS_COMMON) {
   // #pragma usused type
    new 
        idx = 0, 
        last_idx;
	t_string[0] = EOS;
	strcat(t_string, ""colserver"[�] ��������\t"colserver"[���]\n");
    for(new i = GetPlayerPage(playerid) * (MAX_DIALOG_ROWS - 1), string_[128]; i != MAX_ITEMS_COUNT; i++)
	//for(new i = 0, string_[128]; i < MAX_ITEMS_SLOTS; i++)
	{   
        /*if(AccesoryInfo[ i ][accesoryType] == type)
            continue; */
        SetPlayerListitem(playerid, idx, i);
        idx++;
 
		format(string_, sizeof string_, ""colwhi"[%d] %s\t{%s}[%s]\n", idx, 
			AccesoryInfo[i][accesoryName],  colorItems[AccesoryInfo[ i ][accesoryType]], nameItems[AccesoryInfo[ i ][accesoryType]]
		);
		strcat(t_string, string_); 
 
        last_idx = i;
        if(idx == MAX_DIALOG_ROWS)
            break;
	}
    if(idx == MAX_DIALOG_ROWS)
    {
        if(last_idx != MAX_ITEMS_SLOTS && GetPlayerPage(playerid) >= 1) {
            strcat(t_string, "��������� �������� >>\t\n���������� �������� <<");
            
            SetPlayerListitem(playerid, idx, PAGE_VALUE_NEXT);
            SetPlayerListitem(playerid, idx + 1, PAGE_VALUE_BACK);
        }
        else if(GetPlayerPage(playerid) <= 0 && last_idx != MAX_ITEMS_COUNT) {
            strcat(t_string, "��������� �������� >>");
            
            SetPlayerListitem(playerid, idx, PAGE_VALUE_NEXT);
        }
    } else {
        strcat(t_string, "���������� �������� <<");
        SetPlayerListitem(playerid, idx, PAGE_VALUE_BACK);
    }
    ShowPlayerDialog(playerid, D_PROMO_CODE_REFERAL_11, DIALOG_STYLE_TABLIST_HEADERS, 
        ""colserver"���������: "colwhi"����������", t_string, "�������", "������"
    );
    return 1;
}
 
/*
PromoCode:getPlayerOwnerPromoCode(playerid) {
    new 
        query_[64];
    format(query_, sizeof query_, "SELECT codeID FROM "TABLE_PROMOCODE" WHERE codeID")
    new
        Cache: result = mysql_query(dbHandle, query_), coins_count = 0;
    cache_get_value_int(0, "codeDonate", coins_count);
    if (cache_is_valid(result)) cache_delete(result);
    return coins_count;
}*/
 