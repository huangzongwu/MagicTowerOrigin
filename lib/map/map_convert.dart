import 'package:magic_tower_origin/ability/ability_entry.dart';
import 'package:magic_tower_origin/ability/base_entry.dart';
import 'package:magic_tower_origin/ability/prop_entry.dart';
import 'package:magic_tower_origin/map/map_entities.dart';
import 'package:magic_tower_origin/map/map_info.dart';
import 'package:magic_tower_origin/role/ability_character.dart';
import 'package:magic_tower_origin/role/base_character.dart';
import 'package:magic_tower_origin/role/prop_level.dart';
import 'package:magic_tower_origin/role/prop_role.dart';
import 'package:magic_tower_origin/role/weapon_role.dart';
import 'package:rxdart/rxdart.dart';

class MapConvert {
  static const String CUR_LEVEL = "curLevel";
  static const String HERO = "hero";
  static const String LEVELS = "levels";
  static const String SX = "sx";
  static const String SY = "sy";
  static const String ROLES = "roles";
  static const String TYPE = "type";
  static const String P_HERO = "pHero";

  // 能力 部分
  static const String LIFE = "life";
  static const String ATTACK = "attack";
  static const String DEFEND = "defend";
  static const String MONEY = "money";
  static const String EXPERIENCE = "experience";
  static const String PASSABLE = "passable";
  static const String EQUIPMENT = "equipment";
  static const String ATTACK_WEAPON = "attackWeapon";
  static const String DEFEND_WEAPON = "defendWeapon";

  static const String Y_KEY = "yKey";
  static const String B_KEY = "bKey";
  static const String R_KEY = "rKey";

  static const String PX = "px";
  static const String PY = "py";

  static const String TIMES = "times";
  static const String PROP_TYPE = "propType";
  static const String LEVEL_OFFSET = "levelOffset";

  static Observable<List<BaseCharacter<BaseEntry>>> parseJsonMap(
      Future<dynamic> fJson) {
    return Observable.fromFuture(fJson).map((json) {
      return _convertAndAdjust(json);
    });
  }

  static List<BaseCharacter<BaseEntry>> _convertAndAdjust(List<dynamic> map) {
    List<BaseCharacter<BaseEntry>> list = new List();
    if (map != null) {
      for (var data in map) {
        if (data is Map) {
          BaseCharacter bc = MapConvert._convert(data);
          list.add(bc);
        } else {
          list.add(null);
        }
      }
    }
    return list;
  }

  static BaseCharacter _convert(Map<String, dynamic> data) {
    BaseCharacter character = ME.getEntity(data[TYPE]);
    if (character == null) {
      return null;
    }

    if (character.abilityEntry is AbilityEntry) {
      _loadAbility(character, data);
      _loadEquipment(character, data);
      _loadADWeapon(character, data);
    } else if (character.abilityEntry is PropEntry) {
      _loadProp(character, data);
    }

    _loadBase(character, data);
    return character;
  }

  static _loadAbility(BaseCharacter bc, Map<String, dynamic> data) {
    AbilityEntry ae = bc.abilityEntry;
    ae.setDefend(data[DEFEND]);
    ae.setLife(data[LIFE]);
    ae.setAttack(data[ATTACK]);
    ae.setMoney(data[MONEY]);
    ae.setExperience(data[EXPERIENCE]);

    //钥匙
    ae.setYKey(data[Y_KEY]);
    ae.setBKey(data[B_KEY]);
    ae.setRKey(data[R_KEY]);
  }

 /// 载入攻防武器
  static void _loadADWeapon(
      AbilityCharacter character, Map<String, dynamic> data) {
    Map<String, dynamic> attackJson = data[ATTACK_WEAPON];
    if (attackJson != null) {
      WeaponRole awr = ME.getEntity(attackJson[TYPE]);
      character.setAttackWeapon(awr);
    }

    Map<String, dynamic> defendJson = data[DEFEND_WEAPON];
    if (defendJson != null) {
      WeaponRole dwr = ME.getEntity(defendJson[TYPE]);
      character.setDefendWeapon(dwr);
    }
  }

  /// 载入道具
  static void _loadProp(
      BaseCharacter<BaseEntry> character, Map<String, dynamic> data) {
    PropEntry ae = character.abilityEntry;
    print("loadProploadProploadProp11 ${character.jsonData()}");
    ae.times = data[TIMES] ?? ae.times;
    ae.propType = data[PROP_TYPE] ?? ae.propType;
    print("loadProploadProploadProp22 ${character.jsonData()}");

    if (character is PropLevel) {
      character.offset = data[LEVEL_OFFSET] ?? character.offset;
    }
  }

  static void _loadBase(
      BaseCharacter<BaseEntry> character, Map<String, dynamic> data) {
    var ir = character.imageRender;
    if (data[PX] != null) {
      ir.position[0] = data[PX];
    }
    if (data[PY] != null) {
      ir.position[1] = data[PY];
    }

    bool isPass = data[PASSABLE] != null ? data[PASSABLE] == "1" : null;
    character.abilityEntry.setPassable(isPass);
  }

  /// 载入装备
  static void _loadEquipment(character, Map data) {
    List<dynamic> equipmentJson = data[EQUIPMENT];
    if (equipmentJson == null) {
      return;
    }
    for (var wJson in equipmentJson) {
      BaseCharacter wr = ME.getEntity(wJson[TYPE]);
      print("loadEquipmentloadEquipment ${wr.jsonData()}   $wJson");

      if (wr is PropRole) {
        _loadProp(wr, wJson);
      } else if (wr is WeaponRole) {
        _loadAbility(wr, wJson);
      }
      character.addEquipment(wr);
    }
  }

 /// 转成json
  static back2Original(List<List<BaseCharacter<BaseEntry>>> bcs) {
    List<Map<String, dynamic>> characters = new List();
    for (var i = 0; i < MapInfo.sx; i++) {
      for (var j = 0; j < MapInfo.sy; j++) {
        if (bcs[j][i] != null) {
          characters.add(bcs[j][i].jsonData());
        } else {
          characters.add(null);
        }
      }
    }
    return characters;
  }
}
