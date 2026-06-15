// ════════════════════════════════════════════════════════
//  tabs/map_tab.dart — نسخة العراق (إغاثة)
//  ✅ مدن عراقية: بغداد، البصرة، أربيل، الموصل
//  ✅ إحداثيات دقيقة ومواقع طوارئ محلية
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../core/theme/app_colors.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/permission_service.dart';

class EmergencyPoint {
  final String titleAr, titleEn, typeAr, typeEn, phone, cityAr;
  final LatLng position;
  final Color color;
  final IconData icon;

  const EmergencyPoint({
    required this.titleAr, required this.titleEn,
    required this.typeAr,  required this.typeEn,
    required this.phone,   required this.position,
    required this.color,   required this.icon,
    required this.cityAr,
  });
}

// ════════════════════════════════════════════════════════
//  بيانات نقاط الطوارئ في العراق
// ════════════════════════════════════════════════════════
const List<EmergencyPoint> _allPoints = [
  // بغداد
  EmergencyPoint(titleAr:'مدينة الطب',titleEn:'Medical City',
    typeAr:'مستشفى',typeEn:'Hospital',phone:'122',
    position:LatLng(33.3496,44.3850),color:Color(0xFF1565C0),
    icon:Icons.local_hospital_rounded,cityAr:'بغداد'),
  EmergencyPoint(titleAr:'مركز شرطة الصالحية',titleEn:'Al-Salhiya Police',
    typeAr:'شرطة',typeEn:'Police',phone:'104',
    position:LatLng(33.3250,44.3900),color:Color(0xFF0D47A1),
    icon:Icons.local_police_rounded,cityAr:'بغداد'),
  // البصرة
  EmergencyPoint(titleAr:'مستشفى البصرة التعليمي',titleEn:'Basra Teaching Hospital',
    typeAr:'مستشفى',typeEn:'Hospital',phone:'122',
    position:LatLng(30.5089,47.8160),color:Color(0xFF1565C0),
    icon:Icons.local_hospital_rounded,cityAr:'البصرة'),
  EmergencyPoint(titleAr:'الدفاع المدني - البصرة',titleEn:'Basra Civil Defense',
    typeAr:'دفاع مدني',typeEn:'Civil Defense',phone:'115',
    position:LatLng(30.5200,47.8300),color:Color(0xFFE65100),
    icon:Icons.shield_rounded,cityAr:'البصرة'),
  // أربيل
  EmergencyPoint(titleAr:'مستشفى رزكاري',titleEn:'Rizgary Hospital',
    typeAr:'مستشفى',typeEn:'Hospital',phone:'122',
    position:LatLng(36.1911,44.0092),color:Color(0xFF1565C0),
    icon:Icons.local_hospital_rounded,cityAr:'أربيل'),
  // الموصل
  EmergencyPoint(titleAr:'مستشفى الموصل العام',titleEn:'Mosul General Hospital',
    typeAr:'مستشفى',typeEn:'Hospital',phone:'122',
    position:LatLng(36.3489,43.1577),color:Color(0xFF1565C0),
    icon:Icons.local_hospital_rounded,cityAr:'الموصل'),
];

const Map<String,LatLng> _cityCenters = {
  'بغداد':   LatLng(33.3152,44.3661),
  'البصرة':  LatLng(30.5081,47.7835),
  'أربيل':   LatLng(36.1901,44.0089),
  'الموصل':  LatLng(36.3489,43.1265),
};

class MapTab extends ConsumerStatefulWidget {
  const MapTab({super.key});
  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  late final MapController _mapController;
  LatLng? _userLocation;
  bool _loadingLocation = false;
  String _selectedCity = 'بغداد'; 
  String? _activeFilter;
  EmergencyPoint? _selectedPoint;
  double _currentZoom = 12.0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _tryGetLocation();
  }

  @override
  void dispose() { _mapController.dispose(); super.dispose(); }

  Future<void> _tryGetLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final pos = await PermissionService.instance.getCurrentPosition();
      if (pos != null && mounted) {
        final ll = LatLng(pos.latitude, pos.longitude);
        _detectNearestCity(ll);
        setState(() { _userLocation = ll; _loadingLocation = false; });
        _mapController.move(ll, 13.0);
      } else {
        if (mounted) setState(() => _loadingLocation = false);
      }
    } catch (_) {
      if (mounted) setState(() => _loadingLocation = false);
    }
  }

  void _detectNearestCity(LatLng pos) {
    const dist = Distance();
    String nearest = 'بغداد';
    double minD = double.infinity;
    _cityCenters.forEach((city, center) {
      final d = dist.as(LengthUnit.Kilometer, pos, center);
      if (d < minD) { minD = d; nearest = city; }
    });
    setState(() => _selectedCity = nearest);
  }

  List<EmergencyPoint> get _filtered {
    var pts = _allPoints.where((p) => p.cityAr == _selectedCity).toList();
    if (_activeFilter != null) pts = pts.where((p) => p.typeAr == _activeFilter).toList();
    return pts;
  }

  void _moveToCity(String city) {
    final c = _cityCenters[city];
    if (c != null) { 
      _mapController.move(c, 12.0); 
      setState(() { _selectedCity = city; _selectedPoint = null; }); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAr = ref.watch(languageProvider);
    final pad  = MediaQuery.of(context).padding.top;

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: Stack(children: [
          _buildMap(),
          Positioned(top:0,left:0,right:0, child:_MapHeader(isAr:isAr,
            userLocation:_userLocation,loading:_loadingLocation,onLocate:_tryGetLocation)),
          Positioned(top:pad+74,left:0,right:0, child:_CitySelector(
            isAr:isAr,selected:_selectedCity,onSelect:_moveToCity)),
          Positioned(top:pad+124,left:0,right:0, child:_FilterBar(
            isAr:isAr,active:_activeFilter,
            onFilter:(f)=>setState((){_activeFilter=_activeFilter==f?null:f;_selectedPoint=null;}))),
          Positioned(top:pad+170,left:isAr?null:14,right:isAr?14:null,
            child:_Badge(count:_filtered.length,city:_selectedCity,isAr:isAr)),
          Positioned(bottom:_selectedPoint!=null?235:95,right:14,
            child:_ZoomCtrl(
              onIn:(){_currentZoom=(_currentZoom+1).clamp(3,18);_mapController.move(_mapController.camera.center,_currentZoom);},
              onOut:(){_currentZoom=(_currentZoom-1).clamp(3,18);_mapController.move(_mapController.camera.center,_currentZoom);},
              onMe:(){if(_userLocation!=null)_mapController.move(_userLocation!,14);else _tryGetLocation();})),
          if(_loadingLocation) Positioned(bottom:105,left:0,right:0,
            child:Center(child:_LoadingBadge(isAr:isAr))),
          if(_selectedPoint!=null) Positioned(bottom:0,left:0,right:0,
            child:_PointCard(point:_selectedPoint!,isAr:isAr,
              onClose:()=>setState(()=>_selectedPoint=null))),
        ]),
      ),
    );
  }

  Widget _buildMap() => FlutterMap(
    mapController: _mapController,
    options: MapOptions(
      initialCenter: _cityCenters[_selectedCity]!,
      initialZoom: _currentZoom, minZoom:4, maxZoom:18,
      onTap:(_,__)=>setState(()=>_selectedPoint=null),
      onMapEvent:(e){ if(e is MapEventMove) _currentZoom=e.camera.zoom; },
    ),
    children: [
      TileLayer(urlTemplate:'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName:'com.ighatha.app',maxZoom:19),
      CircleLayer(circles:_filtered.map((p)=>CircleMarker(
        point:p.position,radius:800,useRadiusInMeter:true,
        color:p.color.withOpacity(0.07),
        borderColor:p.color.withOpacity(0.2),borderStrokeWidth:1.5)).toList()),
      if(_userLocation!=null)...[
        CircleLayer(circles:[CircleMarker(
          point:_userLocation!,radius:200,useRadiusInMeter:true,
          color:AppColors.primary.withOpacity(0.15),
          borderColor:AppColors.primary.withOpacity(0.5),borderStrokeWidth:2)]),
        MarkerLayer(markers:[Marker(point:_userLocation!,width:44,height:44,
          child:Container(
            decoration:BoxDecoration(color:AppColors.primary,shape:BoxShape.circle,
              border:Border.all(color:Colors.white,width:3),
              boxShadow:[BoxShadow(color:AppColors.primary.withOpacity(0.4),blurRadius:12)]),
            child:const Icon(Icons.person_pin_rounded,color:Colors.white,size:22)))]),
      ],
      MarkerLayer(markers:_filtered.map((p)=>Marker(
        point:p.position,width:46,height:46,
        child:GestureDetector(
          onTap:(){ _mapController.move(p.position,14.5); setState(()=>_selectedPoint=p); },
          child:_Marker(p:p,sel:_selectedPoint==p)))).toList()),
    ],
  );
}

// ════════════════════════════════════════════════════════
// Widgets المساعدة (نفسها سابقة مع تحديث قوائم المدن)
// ════════════════════════════════════════════════════════

class _Marker extends StatelessWidget {
  final EmergencyPoint p; final bool sel;
  const _Marker({required this.p,required this.sel});
  @override Widget build(BuildContext c)=>AnimatedContainer(
    duration:const Duration(milliseconds:200),
    decoration:BoxDecoration(color:p.color,shape:BoxShape.circle,
      border:Border.all(color:Colors.white,width:sel?3:2),
      boxShadow:[BoxShadow(color:p.color.withOpacity(sel ? 0.5 : 0.3),
        blurRadius:sel?18:8,offset:const Offset(0,3))]),
    child:Icon(p.icon,color:Colors.white,size:sel?24:20));
}

class _MapHeader extends StatelessWidget {
  final bool isAr,loading; final LatLng? userLocation; final VoidCallback onLocate;
  const _MapHeader({required this.isAr,required this.userLocation,
    required this.loading,required this.onLocate});
  @override Widget build(BuildContext c)=>Container(
    padding:EdgeInsets.only(top:MediaQuery.of(c).padding.top+10,
      left:16,right:16,bottom:12),
    decoration:const BoxDecoration(
      gradient:LinearGradient(colors:AppColors.headerGradient,
        begin:Alignment.topLeft,end:Alignment.bottomRight),
      borderRadius:BorderRadius.vertical(bottom:Radius.circular(20))),
    child:Row(children:[
      Container(width:38,height:38,
        decoration:BoxDecoration(color:Colors.white.withOpacity(.2),
          borderRadius:BorderRadius.circular(11)),
        child:const Icon(Icons.map_rounded,color:Colors.white,size:20)),
      const SizedBox(width:11),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(isAr?'خريطة الطوارئ':'Emergency Map',
          style:GoogleFonts.cairo(fontSize:17,fontWeight:FontWeight.w900,color:Colors.white)),
        Text(userLocation!=null?(isAr?'📍 تم تحديد موقعك':'📍 Location detected')
          :(isAr?'اختر مدينة عراقية أو فعّل الموقع':'Select city or enable location'),
          style:GoogleFonts.cairo(fontSize:11,color:Colors.white70)),
      ])),
      GestureDetector(onTap:onLocate,child:Container(
        padding:const EdgeInsets.symmetric(horizontal:10,vertical:6),
        decoration:BoxDecoration(
          color:userLocation!=null?const Color(0xFF43A047).withOpacity(.85)
            :Colors.white.withOpacity(.2),
          borderRadius:BorderRadius.circular(20)),
        child:Row(mainAxisSize:MainAxisSize.min,children:[
          if(loading) const SizedBox(width:12,height:12,
            child:CircularProgressIndicator(color:Colors.white,strokeWidth:2))
          else Icon(userLocation!=null?Icons.location_on_rounded
            :Icons.location_off_rounded,color:Colors.white,size:14),
          const SizedBox(width:5),
          Text(isAr?'موقعي':'My Location',style:GoogleFonts.cairo(
            fontSize:11,color:Colors.white,fontWeight:FontWeight.w600)),
        ]))),
    ]));
}

class _CitySelector extends StatelessWidget {
  final bool isAr; final String selected; final ValueChanged<String> onSelect;
  const _CitySelector({required this.isAr,required this.selected,required this.onSelect});
  @override Widget build(BuildContext c){
    const ar=['بغداد','البصرة','أربيل','الموصل'];
    const en=['Baghdad','Basra','Erbil','Mosul'];
    return SizedBox(height:42,child:ListView.separated(
      scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),
      itemCount:ar.length,separatorBuilder:(_,__)=>const SizedBox(width:7),
      itemBuilder:(_,i){final sel=selected==ar[i];return GestureDetector(
        onTap:()=>onSelect(ar[i]),child:AnimatedContainer(
          duration:const Duration(milliseconds:200),
          padding:const EdgeInsets.symmetric(horizontal:13,vertical:7),
          decoration:BoxDecoration(color:sel?AppColors.primary:Colors.white,
            borderRadius:BorderRadius.circular(21),
            boxShadow:[BoxShadow(color:sel?AppColors.primary.withOpacity(.35)
              :Colors.black.withOpacity(.07),blurRadius:7,offset:const Offset(0,2))]),
          child:Row(mainAxisSize:MainAxisSize.min,children:[
            Icon(Icons.location_city_rounded,size:13,
              color:sel?Colors.white:AppColors.textGray),
            const SizedBox(width:5),
            Text(isAr?ar[i]:en[i],style:GoogleFonts.cairo(fontSize:11,
              fontWeight:FontWeight.w700,
              color:sel?Colors.white:AppColors.textDark)),
          ])));},));
  }
}

class _FilterBar extends StatelessWidget {
  final bool isAr; final String? active; final ValueChanged<String> onFilter;
  const _FilterBar({required this.isAr,required this.active,required this.onFilter});
  @override Widget build(BuildContext c){
    const ar=['مستشفى','شرطة','إطفاء','إسعاف','دفاع مدني'];
    const en=['Hospital','Police','Fire','Ambulance','Civil Defense'];
    const icons=[Icons.local_hospital_rounded,Icons.local_police_rounded,
      Icons.local_fire_department_rounded,Icons.medical_services_rounded,Icons.shield_rounded];
    const cols=[Color(0xFF1565C0),Color(0xFF0D47A1),Color(0xFFC62828),
      Color(0xFF2E7D32),Color(0xFFE65100)];
    return SizedBox(height:38,child:ListView.separated(
      scrollDirection:Axis.horizontal,padding:const EdgeInsets.symmetric(horizontal:12),
      itemCount:ar.length,separatorBuilder:(_,__)=>const SizedBox(width:6),
      itemBuilder:(_,i){final isSel=active==ar[i];return GestureDetector(
        onTap:()=>onFilter(ar[i]),child:AnimatedContainer(
          duration:const Duration(milliseconds:200),
          padding:const EdgeInsets.symmetric(horizontal:9,vertical:5),
          decoration:BoxDecoration(color:isSel?cols[i]:Colors.white.withOpacity(.92),
            borderRadius:BorderRadius.circular(19),
            border:Border.all(color:cols[i].withOpacity(.3)),
            boxShadow:[BoxShadow(color:isSel?cols[i].withOpacity(.3)
              :Colors.black.withOpacity(.05),blurRadius:5,offset:const Offset(0,2))]),
          child:Row(mainAxisSize:MainAxisSize.min,children:[
            Icon(icons[i],color:isSel?Colors.white:cols[i],size:12),
            const SizedBox(width:4),
            Text(isAr?ar[i]:en[i],style:GoogleFonts.cairo(fontSize:11,
              fontWeight:FontWeight.w700,
              color:isSel?Colors.white:AppColors.textDark)),
          ])));},));
  }
}

class _Badge extends StatelessWidget {
  final int count; final String city; final bool isAr;
  const _Badge({required this.count,required this.city,required this.isAr});
  @override Widget build(BuildContext c)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:5),
    decoration:BoxDecoration(color:AppColors.primary.withOpacity(.88),
      borderRadius:BorderRadius.circular(20),
      boxShadow:const[BoxShadow(color:Color(0x30000000),blurRadius:5)]),
    child:Text(isAr?'$count موقع في $city':'$count sites in $city',
      style:GoogleFonts.cairo(fontSize:11,color:Colors.white,fontWeight:FontWeight.w700)));
}

class _ZoomCtrl extends StatelessWidget {
  final VoidCallback onIn,onOut,onMe;
  const _ZoomCtrl({required this.onIn,required this.onOut,required this.onMe});
  @override Widget build(BuildContext c)=>Column(children:[
    _ZBtn(icon:Icons.add_rounded,onTap:onIn),const SizedBox(height:6),
    _ZBtn(icon:Icons.remove_rounded,onTap:onOut),const SizedBox(height:6),
    _ZBtn(icon:Icons.my_location_rounded,onTap:onMe,color:AppColors.primary)]);
}

class _ZBtn extends StatelessWidget {
  final IconData icon; final VoidCallback onTap; final Color? color;
  const _ZBtn({required this.icon,required this.onTap,this.color});
  @override Widget build(BuildContext c)=>GestureDetector(onTap:onTap,
    child:Container(width:40,height:40,
      decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(12),
        boxShadow:const[BoxShadow(color:Color(0x22000000),blurRadius:8,offset:Offset(0,2))]),
      child:Icon(icon,color:color??AppColors.primary,size:20)));
}

class _LoadingBadge extends StatelessWidget {
  final bool isAr;
  const _LoadingBadge({required this.isAr});
  @override Widget build(BuildContext c)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:16,vertical:8),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(20),
      boxShadow:const[BoxShadow(color:Color(0x22000000),blurRadius:10)]),
    child:Row(mainAxisSize:MainAxisSize.min,children:[
      const SizedBox(width:14,height:14,
        child:CircularProgressIndicator(color:AppColors.primary,strokeWidth:2.5)),
      const SizedBox(width:8),
      Text(isAr?'جاري تحديد موقعك...':'Detecting location...',
        style:GoogleFonts.cairo(fontSize:12,color:AppColors.textDark,fontWeight:FontWeight.w600))]));
}

class _PointCard extends StatelessWidget {
  final EmergencyPoint point; final bool isAr; final VoidCallback onClose;
  const _PointCard({required this.point,required this.isAr,required this.onClose});
  @override Widget build(BuildContext c)=>Container(
    margin:const EdgeInsets.fromLTRB(12,0,12,12),
    padding:const EdgeInsets.fromLTRB(16,12,16,16),
    decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(22),
      boxShadow:const[BoxShadow(color:Color(0x22000000),blurRadius:20,offset:Offset(0,-4))]),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:36,height:4,decoration:BoxDecoration(
        color:Colors.grey.shade300,borderRadius:BorderRadius.circular(2))),
      const SizedBox(height:14),
      Row(children:[
        Container(width:52,height:52,
          decoration:BoxDecoration(color:point.color.withOpacity(.12),
            borderRadius:BorderRadius.circular(15)),
          child:Icon(point.icon,color:point.color,size:26)),
        const SizedBox(width:14),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text(isAr?point.titleAr:point.titleEn,style:GoogleFonts.cairo(
            fontSize:14,fontWeight:FontWeight.w800,color:AppColors.textDark)),
          const SizedBox(height:4),
          Row(children:[
            Container(padding:const EdgeInsets.symmetric(horizontal:8,vertical:3),
              decoration:BoxDecoration(color:point.color.withOpacity(.1),
                borderRadius:BorderRadius.circular(8)),
              child:Text(isAr?point.typeAr:point.typeEn,style:GoogleFonts.cairo(
                fontSize:10,color:point.color,fontWeight:FontWeight.w700))),
            const SizedBox(width:6),
            Icon(Icons.location_city_rounded,color:AppColors.textGray,size:11),
            const SizedBox(width:3),
            Text(point.cityAr,style:GoogleFonts.cairo(fontSize:10,color:AppColors.textGray)),
          ]),
        ])),
        GestureDetector(onTap:onClose,child:Container(width:30,height:30,
          decoration:BoxDecoration(color:AppColors.bg,borderRadius:BorderRadius.circular(9)),
          child:const Icon(Icons.close_rounded,color:AppColors.textGray,size:16))),
      ]),
      const SizedBox(height:12),
      Row(children:[
        Expanded(child:_Chip(icon:Icons.phone_rounded,label:point.phone,color:const Color(0xFF2E7D32))),
        const SizedBox(width:8),
        Expanded(child:_Chip(icon:Icons.access_time_rounded,
          label:isAr?'مفتوح 24 ساعة':'Open 24h',color:AppColors.primary)),
      ]),
      const SizedBox(height:12),
      Row(children:[
        Expanded(child:OutlinedButton.icon(onPressed:(){},
          icon:const Icon(Icons.directions_rounded,size:16),
          label:Text(isAr?'الاتجاهات':'Directions',
            style:GoogleFonts.cairo(fontSize:13,fontWeight:FontWeight.w700)),
          style:OutlinedButton.styleFrom(foregroundColor:AppColors.primary,
            side:const BorderSide(color:AppColors.primary),
            shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
            padding:const EdgeInsets.symmetric(vertical:10)))),
        const SizedBox(width:10),
        Expanded(child:ElevatedButton.icon(onPressed:(){},
          icon:const Icon(Icons.phone_rounded,size:16),
          label:Text(isAr?'اتصال':'Call',
            style:GoogleFonts.cairo(fontSize:13,fontWeight:FontWeight.w700)),
          style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,
            foregroundColor:Colors.white,elevation:0,
            shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),
            padding:const EdgeInsets.symmetric(vertical:10)))),
      ]),
    ]));
}

class _Chip extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _Chip({required this.icon,required this.label,required this.color});
  @override Widget build(BuildContext c)=>Container(
    padding:const EdgeInsets.symmetric(horizontal:10,vertical:8),
    decoration:BoxDecoration(color:color.withOpacity(.07),
      borderRadius:BorderRadius.circular(10),
      border:Border.all(color:color.withOpacity(.2))),
    child:Row(mainAxisSize:MainAxisSize.min,children:[
      Icon(icon,color:color,size:13),const SizedBox(width:5),
      Flexible(child:Text(label,style:GoogleFonts.cairo(fontSize:11,color:color,
        fontWeight:FontWeight.w600),overflow:TextOverflow.ellipsis))]));
}