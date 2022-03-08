
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// @author : istiklal

class AboutAppScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Faktoring Çek/Senet Uygulaması"),
      ),
      body: aboutApplication(context),
    );
  }

  aboutApplication(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text("Faktoring Çek/Senet -- Version : 1.0", textAlign: TextAlign.center,),
            ),
            Divider(indent: 8, endIndent: 8, thickness: 1.2),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                "Bu uygulama çek ve senetlerinizi, faktoring kullanımlarınızı, faktoring risk seviyenizi, "
                "bu ödeme enstrumanlarından kaynaklı nakit akışınızı takip edebilmenizi sağlamanın yanı sıra "
                "faktoring kullanımlarınızda faiz, komisyon ve masraf bilgilerini girerek kolayca "
                "faktoring ödeme tutarını hesaplayabilmenizi ve yaptığınız faktoring işleminin ödeme tutarını "
                "kontrol edebilmenizi amaçlamaktadır. "
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                "Faktoring şirketine toplu olarak verdiğiniz bir bordroyu hesaplayabilmek için bordro içindeki "
                "çekler veya senetleri uygulamaya kaydedip bir portföy oluşturarak tıpkı faktoring şirketine "
                "vermiş olduğunuz bordroyu hesaplar gibi tek seferde tüm bordro için faktoring hesaplaması yapabilir "
                "hatta toplu yapılmış olan bu kullanımın tek tek her bir çek veya senet başına maliyetlerini "
                "net olarak görebilirsiniz."
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                "Tek bir çek için hiçbir kayıt yaratmadan hızlıca ödeme tutarını hesaplayabileceğiniz bir faktoring "
                "hesap makinası da yer almaktadır. Faktoring Hesapla butonuna bastığınızda bu hesaplama formuna "
                "ulaşabilirsiniz. Tek yapmanız gereken tutar ve vadeyi girdikten sonra faktoring şirketinin size "
                "söylediği faiz oranı, komisyon oranı ve işlem masrafını yazmak, size belirtilen ödeme tutarını "
                "buradan rahatlıkla teyit edebilirsiniz."
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                "- Bu uygulama üyelik istememektedir,\n"
                "- Kayıt ettiğiniz çek, senet ve portföy bilgileri bütünüyle cihazınızda tutulur, ve sadece cihazınızda "
                "yüklü olan Faktoring Çek/Senet uygulaması tarafından faktoring hesaplamalarınızı yapmak ve nakit "
                "akışınıza dair özet bilgiler sunabilmek için uygulama tarafından kullanılır."
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                  "- Bu uygulama İstiklal Güneş tarafından tasarlanmış ve geliştirilmiştir, tüm hakları saklıdır. "
              ),
            )
          ],
        ),
      ),
    );
  }

}