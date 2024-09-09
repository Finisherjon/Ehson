part of 'yordam_bloc.dart';

enum YordamProduct { loading, success, error }

class YordamState extends Equatable {
  final YordamProduct status;
  final List<Data> products;
  final bool islast;
  final String errorMessage;
  final String? nextPageUrl;

  //bera qaysi tartibga yozgasiz
  //qanoqa tartib
  //boshqachaku
  //shunay bera equatable qilingan block technalogiya buyam faqat boshqacharoq
  //scroll qigan payt boshqa tavarlaniyam olish uchun shunay qilish kerak
  //agar faqat bir marta serverdan malumot osan va o'zgarmasa eski yul bilan qisan buladi
  //agar scroll qigan payt serverdan malumot olib bor malumotni yonidan qushish kerak busa shunoqa yul qilinadi
  //xay buni birorota saytdan taxlasa buladimi xuddi json to dartday
  //mana tayor home block borku buni unoqa qimaysan uzin yozaman sanga tayor example home block xuddi shunay yozilgan

  const YordamState(
      {this.status = YordamProduct.loading,
        this.islast = false,
        this.products = const [],
        this.errorMessage = "",
        this.nextPageUrl = ""
      });

  YordamState copyWith({
    YordamProduct? status,
    List<Data>? products,
    bool? islast,
    String? errorMessage,
    String? nextPageUrl,
  }) {
    return YordamState(
      status: status ?? this.status,
      products: products ?? this.products,
      islast: islast ?? this.islast,
      errorMessage: errorMessage ?? this.errorMessage,
      nextPageUrl: nextPageUrl,
    );
  }

  @override
  List<Object?> get props => [status, products, islast, errorMessage,nextPageUrl];
}
