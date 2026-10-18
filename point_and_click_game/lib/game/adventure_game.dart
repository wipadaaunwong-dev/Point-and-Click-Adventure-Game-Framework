import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'hotspot.dart';
import 'inventory.dart';

class AdventureGame extends FlameGame {
  final InventoryManager inventory;
  final Function(String title, String description, {String? characterImage, VoidCallback? onDismiss}) showDialogue;
  final VoidCallback onDemoEnd;

  AdventureGame({
    required this.inventory,
    required this.showDialogue,
    required this.onDemoEnd,
  });

  late SpriteComponent _background;
  int currentRoom = 0;
  final List<Hotspot> _activeHotspots = [];
  final Random _random = Random();
  Vector2? _currentKeyPosition;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _background = SpriteComponent(size: size);
    add(_background);

    await loadRoom(0);
    _showIntroStory();
  }

  void _showIntroStory() {
    showDialogue(
      '🌆 ตอนเย็นวันหนึ่ง...',
      'คุณเพิ่งเดินทางกลับมาจากโรงเรียนในตอนเย็น...\n'
      'แต่เมื่อมองไปที่บ้าน ตัวบ้านกลับดูเงียบสงบและมีบรรยากาศแปลกไปจากเดิมอย่างสิ้นเชิง...',
    );

  }

  Future<void> loadRoom(int roomNumber) async {
    currentRoom = roomNumber;
    _currentKeyPosition = null;

    for (var hotspot in _activeHotspots) {
      hotspot.removeFromParent();
    }
    _activeHotspots.clear();

    final bgSprite = await loadSprite('bg_room$roomNumber.png');
    _background.sprite = bgSprite;

    if (roomNumber == 0) {
      _setupRoom0Entrance();
    } else if (roomNumber == 1) {
      _setupRoom1Kitchen();
    } else if (roomNumber == 2) {
      _setupRoom2LivingRoom();
    } else if (roomNumber == 3) {
      _setupRoom3Bedroom();
    } else if (roomNumber == 4) {
      _setupRoom4ThreeDoors();
    }
  }

  // 💡 ปุ่มเฉลยตำแหน่งกุญแจ + บทพูดเยาะเย้ยของอลิส
  void revealKeyLocation() {
    if (inventory.hasItem('key')) {
      showDialogue(
        'Alice',
        'แหม... ก็เก็บกุญแจไปอยู่ในกระเป๋าแล้วไม่ใช่หรือไงคะ! จะกดดูเฉลยทำไมอีกเนี่ย หึๆ 😜',
        characterImage: 'alice02.png',
      );
    } else if (_currentKeyPosition != null) {
      String posHint = 'ลองมองหาดูดีๆ บริเวณกลางห้องสิ!';
      if (_currentKeyPosition!.x < size.x * 0.4) {
        posHint = 'กุญแจมันลอยอยู่ทาง "ฝั่งซ้าย" ของห้องต่างหากล่ะ!';
      } else if (_currentKeyPosition!.x > size.x * 0.6) {
        posHint = 'กุญแจมันลอยอยู่ทาง "ฝั่งขวา" ของห้องต่างหากล่ะ!';
      }

      showDialogue(
        'Alice',
        'ฮ่าๆๆ! แค่หากุญแจแค่นี้ก็หาไม่เจอจนต้องกดเฉลยแล้วเหรอเนี่ย? กระจอกจังเลยนะ! 😜\n\n'
        'เอ้า... ยอมบอกให้ก็ได้! $posHint ลอยเด่นขนาดนั้นยังมองไม่เห็นอีกนะ!',
        characterImage: 'alice02.png',
      );
    } else {
      showDialogue(
        'Alice',
        'ห้องนี้ไม่มีกุญแจซ่อนอยู่หรอกนะ! ตั้งสติหน่อยสิคะ! ',
        characterImage: 'alice.png',
      );
    }
  }

  // 🏡 Room 0: หน้าประตูบ้าน
  void _setupRoom0Entrance() {
    _addHotspot(
      id: 'house_door',
      name: 'Door',
      pos: Vector2(size.x * 0.4, size.y * 0.3),
      sizeVec: Vector2(size.x * 0.2, size.y * 0.5),
      onTap: () {
        showDialogue(
          '🚪 ประตูบ้าน',
          'คุณตัดสินใจผลักประตูบ้านเข้าไป...',
          onDismiss: () => loadRoom(1),
        );
      },
    );
  }

  // 🍳 Room 1: ห้องครัว
  void _setupRoom1Kitchen() {
    showDialogue(
      'Alice',
      'สวัสดี! ฉันชื่อ "อลิส" นะ... บ้านของคุณถูกคำสาปปริศนาทำให้ข้าวของลอยกระจัดกระจายไปหมด!\n'
      'ถ้าอยากหาทางออกจากบ้านหลังนี้ คุณต้องไขปริศนาหา "กุญแจ" ที่ลอยอยู่ในห้องเพื่อเปิดประตูไปต่อให้ได้!',
      characterImage: 'alice.png',
    );

    _addVocabHotspot('fridge', '🧊 Refrigerator / Fridge (รีฟริจเจอเรเทอร์ / ฟริดจ์)', 'แปลว่า: ตู้เย็น', Vector2(size.x * 0.0, size.y * 0.32), Vector2(size.x * 0.28, size.y * 0.68));
    _addVocabHotspot('microwave', '♨️ Microwave oven (ไมโครเวฟ โอเวน)', 'แปลว่า: เตาอบไมโครเวฟ', Vector2(size.x * 0.13, size.y * 0.08), Vector2(size.x * 0.22, size.y * 0.32));
    _addVocabHotspot('coffeemaker', '☕ Coffeemaker (คอฟฟี่เมกเกอร์)', 'แปลว่า: เครื่องทำกาแฟ', Vector2(size.x * 0.34, size.y * 0.60), Vector2(size.x * 0.13, size.y * 0.28));
    _addVocabHotspot('toaster', '🍞 Toaster (โทสเทอร์)', 'แปลว่า: เตาปิ้งขนมปัง', Vector2(size.x * 0.45, size.y * 0.41), Vector2(size.x * 0.12, size.y * 0.20));
    _addVocabHotspot('rice_cooker', '🍚 Rice cooker (ไรซ์ คุกเกอร์)', 'แปลว่า: หม้อหุงข้าว', Vector2(size.x * 0.62, size.y * 0.10), Vector2(size.x * 0.17, size.y * 0.30));
    _addVocabHotspot('kettle', '🫖 Kettle (เคทเทิล)', 'แปลว่า: กาน้ำร้อน / กาต้มน้ำ', Vector2(size.x * 0.79, size.y * 0.68), Vector2(size.x * 0.20, size.y * 0.32));

    _addDoorHotspotCustom(
      nextRoomTarget: 2,
      pos: Vector2(size.x * 0.76, size.y * 0.36),
      sizeVec: Vector2(size.x * 0.18, size.y * 0.52),
    );

    _spawnRandomKey();
  }

  // 🛋️ Room 2: ห้องนั่งเล่น
  void _setupRoom2LivingRoom() {
    showDialogue(
      'Alice',
      'เละไปหมดเลย ถ้าอยากเห็นเป็นเหมือนเดิม เธอก็ต้องรีบจัดการแล้วละ!',
      characterImage: 'alice01.png',
    );
  
    _addVocabHotspot('tv', '📺 Television - TV (เทเลวิชัน / ทีวี)', 'แปลว่า: โทรทัศน์', Vector2(size.x * 0.0, size.y * 0.56), Vector2(size.x * 0.25, size.y * 0.44));
    _addVocabHotspot('coffee_table', '☕ Coffee table (คอฟฟี่ เทเบิล)', 'แปลว่า: โต๊ะกาแฟ / โต๊ะเตี้ยหน้าโซฟา', Vector2(size.x * 0.29, size.y * 0.18), Vector2(size.x * 0.27, size.y * 0.36));
    _addVocabHotspot('remote', '📱 Remote control (รีโมท คอนโทรล)', 'แปลว่า: รีโมทคอนโทรล', Vector2(size.x * 0.46, size.y * 0.05), Vector2(size.x * 0.04, size.y * 0.17));
    _addVocabHotspot('vase', '🏺 Vase (เวส)', 'แปลว่า: แจกัน', Vector2(size.x * 0.43, size.y * 0.58), Vector2(size.x * 0.10, size.y * 0.25));
    _addVocabHotspot('curtain', '🪟 Curtain (เคอร์เทน)', 'แปลว่า: ผ้าม่าน / หน้าต่าง', Vector2(size.x * 0.33, size.y * 0.21), Vector2(size.x * 0.41, size.y * 0.49));
    _addVocabHotspot('bookshelf', '📚 Bookshelf (บุ๊กเชลฟ์)', 'แปลว่า: ชั้นวางหนังสือ', Vector2(size.x * 0.67, size.y * 0.54), Vector2(size.x * 0.20, size.y * 0.35));
    _addVocabHotspot('sofa', '🛋️ Sofa / Couch (โซฟา / คาวช์)', 'แปลว่า: โซฟา / เก้าอี้ยาว', Vector2(size.x * 0.64, size.y * 0.0), Vector2(size.x * 0.35, size.y * 0.58));

    _addDoorHotspotCustom(
      nextRoomTarget: 3,
      pos: Vector2(size.x * 0.07, size.y * 0.36),
      sizeVec: Vector2(size.x * 0.18, size.y * 0.52),
    );

    _spawnRandomKey();
  }

  // 🛏️ Room 3: ห้องนอน
  void _setupRoom3Bedroom() {
    showDialogue(
      'Alice',
      'ใกล้จะถึงทางออกแล้วล่ะ! นี่เป็นห้องสุดท้ายที่มีข้าวของลอยกระจัดกระจายแล้วนะ',
      characterImage: 'alice.png',
    );
    showDialogue(
      'Alice',
      'รีบหากุญแจไขไปห้องถัดไปได้แล้ว! หน้าบานประตูทางออกรอคุณไม่อยู่นะ!',
      characterImage: 'alice.png',
    );
    

    _addVocabHotspot('pillow', '☁️ Pillow (พิลโลว์)', 'แปลว่า: หมอน', Vector2(size.x * 0.01, size.y * 0.09), Vector2(size.x * 0.23, size.y * 0.37));
    _addVocabHotspot('dressing_table', '🪞 Dressing table (เดรสซิง เทเบิล)', 'แปลว่า: โต๊ะเครื่องแป้ง', Vector2(size.x * 0.01, size.y * 0.54), Vector2(size.x * 0.16, size.y * 0.41));
    _addVocabHotspot('alarm_clock', '⏰ Alarm clock (อะลาร์ม คล็อก)', 'แปลว่า: นาฬิกาปลุก', Vector2(size.x * 0.64, size.y * 0.19), Vector2(size.x * 0.11, size.y * 0.24));
    _addVocabHotspot('wardrobe', '🚪 Wardrobe / Closet (วอร์ดโรบ / คลอเซ็ท)', 'แปลว่า: ตู้เสื้อผ้า', Vector2(size.x * 0.28, size.y * 0.40), Vector2(size.x * 0.56, size.y * 0.59));
    _addVocabHotspot('bed', '🛏️ Bed (เบด)', 'แปลว่า: เตียงนอน', Vector2(size.x * 0.78, size.y * 0.32), Vector2(size.x * 0.22, size.y * 0.68));

    _addDoorHotspotCustom(
      nextRoomTarget: 4,
      pos: Vector2(size.x * 0.18, size.y * 0.36),
      sizeVec: Vector2(size.x * 0.18, size.y * 0.52),
    );

    _spawnRandomKey();
  }

  // 🚪🚪🚪 Room 4: ประตู 3 บาน
  void _setupRoom4ThreeDoors() {
    showDialogue(
      '❓ ห้องปริศนาประตู 3 บาน',
      'ข้างหน้าของคุณมีประตูอยู่ 3 บาน... เลือกเปิดบานไหนก็ได้เพื่อหาทางออก!',
    );

    _addHotspot(id: 'door_1', name: 'Door 1', pos: Vector2(size.x * 0.2, size.y * 0.3), sizeVec: Vector2(80, 180), onTap: onDemoEnd);
    _addHotspot(id: 'door_2', name: 'Door 2', pos: Vector2(size.x * 0.45, size.y * 0.3), sizeVec: Vector2(80, 180), onTap: onDemoEnd);
    _addHotspot(id: 'door_3', name: 'Door 3', pos: Vector2(size.x * 0.7, size.y * 0.3), sizeVec: Vector2(80, 180), onTap: onDemoEnd);
  }

  // 🔑 สปอว์นรูปกุญแจ key.png
  void _spawnRandomKey() async {
    final randomX = size.x * (0.2 + _random.nextDouble() * 0.45);
    final randomY = size.y * (0.3 + _random.nextDouble() * 0.35);

    _currentKeyPosition = Vector2(randomX, randomY);

    final keySprite = await loadSprite('key.png');
    final keyComponent = SpriteComponent(
      sprite: keySprite,
      position: Vector2.zero(),
      size: Vector2(45, 45),
    );

    final keyHotspot = Hotspot(
      id: 'key',
      name: 'Key',
      position: _currentKeyPosition!,
      size: Vector2(45, 45),
      onTapAction: (_) {
        if (!inventory.hasItem('key')) {
          inventory.addItem('key');
          showDialogue(
            '🔑 Key (คีย์)',
            'คุณคว้ากุญแจที่ลอยอยู่ได้แล้ว! นำไปไขเปิดประตูห้องต่อไปได้เลย',
          );
        }
      },
    );

    keyHotspot.add(keyComponent);
    _activeHotspots.add(keyHotspot);
    add(keyHotspot);
  }

  void _addDoorHotspotCustom({required int nextRoomTarget, required Vector2 pos, required Vector2 sizeVec}) {
    _addHotspot(
      id: 'next_door',
      name: 'Exit Door',
      pos: pos,
      sizeVec: sizeVec,
      onTap: () {
        if (inventory.selectedItem == 'key') {
          inventory.removeItem('key');
          showDialogue(
            '🔓 เปิดประตูสำเร็จ!',
            'คุณใช้กุญแจไขประตูไปยังห้องถัดไป...',
            onDismiss: () => loadRoom(nextRoomTarget),
          );
        } else {
          showDialogue(
            '🔒 ประตูล็อคอยู่',
            'คุณต้องหากุญแจที่ลอยอยู่ในห้องนี้ และเลือกกดใช้งานจากกระเป๋าด้านล่างก่อน!',
          );
        }
      },
    );
  }

  void _addVocabHotspot(String id, String title, String desc, Vector2 pos, Vector2 sizeVec) {
    _addHotspot(
      id: id,
      name: title,
      pos: pos,
      sizeVec: sizeVec,
      onTap: () => showDialogue(title, desc),
    );
  }

  void _addHotspot({
    required String id,
    required String name,
    required Vector2 pos,
    required Vector2 sizeVec,
    required VoidCallback onTap,
  }) {
    final hotspot = Hotspot(
      id: id,
      name: name,
      position: pos,
      size: sizeVec,
      onTapAction: (_) => onTap(),
    );
    _activeHotspots.add(hotspot);
    add(hotspot);
  }
}