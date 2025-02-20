import 'dart:math';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:thunderapp/components/buttons/primary_button.dart';
import 'package:thunderapp/components/utils/vertical_spacer_box.dart';
import 'package:thunderapp/screens/home/home_screen.dart';
import 'package:thunderapp/screens/my_store/my_store_controller.dart';
import 'package:thunderapp/shared/constants/app_enums.dart';
import 'package:thunderapp/shared/constants/style_constants.dart';
import 'package:thunderapp/shared/core/models/banca_model.dart';
import '../../components/forms/custom_text_form_field.dart';
import '../../shared/components/dialogs/default_alert_dialog.dart';
import 'components/circle_image_profile.dart';

class EditStoreScreen extends StatefulWidget {
  BancaModel? bancaModel;

  EditStoreScreen(this.bancaModel, {Key? key}) : super(key: key);

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  String? startTime;
  String? endTime;

  @override
  void initState() {
    super.initState();

    final MyStoreController controller = Get.put(MyStoreController());
    controller.horarioAberturaController.text =
        widget.bancaModel?.horarioAbertura ?? '';
    controller.horarioFechamentoController.text =
        widget.bancaModel?.horarioFechamento ?? '';
    controller.nomeBancaController.text = widget.bancaModel?.nome ?? '';

    controller.pixController.text = widget.bancaModel?.pix ?? '';
    controller.pixBool =
        widget.bancaModel?.pix != null && widget.bancaModel!.pix.isNotEmpty;

    // Definir os itens selecionados de acordo com as formas de pagamento
    String formasPagamento = "1,2,3";
    List<String> pagamentoSelecionado = formasPagamento.split(",");

    controller.isSelected[0] = pagamentoSelecionado.contains("1"); // Dinheiro
    controller.isSelected[1] = pagamentoSelecionado.contains("2"); // PIX
    controller.isSelected[2] = pagamentoSelecionado.contains("3"); // Cartão
  }

  TimeOfDay _getInitialTime(TextEditingController controller) {
    final timeParts = controller.text.split(':');
    if (timeParts.length == 2) {
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return TimeOfDay.now();
  }

  String _formatTimeOfDayTo24Hour(TimeOfDay time) {
    final String hour = time.hour.toString().padLeft(2, '0');
    final String minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final double? doubleFrete =
        double.tryParse(widget.bancaModel?.precoMin ?? '');

    final String freteCorreto =
        doubleFrete != null ? doubleFrete.toStringAsFixed(2) : '';

    const String red = '\x1B[31m';
    const String reset = '\x1B[0m';

    Size size = MediaQuery.of(context).size;

    return GetBuilder<MyStoreController>(
      init: MyStoreController(),
      builder: (controller) => GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: kPrimaryColor,
            title: Center(
              child: Text(
                'Editar banca',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: size.height * 0.030,
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Form(
              key: controller.formKey,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 26,
                  right: 26,
                  bottom: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleImageProfile(controller),
                    ),
                    Divider(
                      height: size.height * 0.016,
                      color: Colors.transparent,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nome da banca',
                          style: TextStyle(
                            color: kSecondaryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: size.height * 0.018,
                          ),
                        ),
                        SizedBox(
                          width: size.width,
                          child: Card(
                            margin: EdgeInsets.zero,
                            elevation: 0,
                            child: ClipPath(
                              child: Container(
                                alignment: Alignment.center,
                                child: CustomTextFormField(
                                  autoValidate:
                                      AutovalidateMode.onUserInteraction,
                                  hintText: widget.bancaModel?.nome ?? '',
                                  erroStyle: const TextStyle(fontSize: 12),
                                  validatorError: (value) {
                                    if (value.isNotEmpty && value.length < 3) {
                                      return 'O nome deve ter no mínimo 3 caracteres';
                                    }
                                    return null;
                                  },
                                  controller: controller.nomeBancaController,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const VerticalSpacerBox(size: SpacerSize.small),
                    Divider(
                      height: size.height * 0.01,
                      color: Colors.transparent,
                    ),
                    SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Horário de abertura',
                                style: TextStyle(
                                  color: kSecondaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: size.height * 0.018,
                                ),
                              ),
                              Divider(height: size.height * 0.006, color: Colors.transparent),
                              IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: () async {
                                  final selectedTime = await showTimePicker(
                                    context: context,
                                    cancelText: "Cancelar",
                                    confirmText: "Confirmar",
                                    hourLabelText: "Horas",
                                    minuteLabelText: "Minutos",
                                    helpText: "Insira o horário:",
                                    initialTime: _getInitialTime(controller.horarioAberturaController),
                                    initialEntryMode: TimePickerEntryMode.inputOnly,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: kPrimaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: kPrimaryColor,
                                          ),
                                        ),
                                        child: MediaQuery(
                                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                          child: child!,
                                        ),
                                      );
                                    },
                                  );

                                  if (selectedTime != null) {
                                    final formattedTime = _formatTimeOfDayTo24Hour(selectedTime);
                                    final fechamentoTime = controller.horarioFechamentoController.text;

                                    if (fechamentoTime.isNotEmpty &&
                                        _isClosingTimeInvalid(formattedTime, fechamentoTime)) {
                                      _showSnackbar(context, "O horário de abertura deve ser menor que o de fechamento.");
                                      return;
                                    }

                                    setState(() {
                                      controller.horarioAberturaController.text = formattedTime;
                                    });
                                  }
                                },
                              ),
                              if (controller.horarioAberturaController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    controller.horarioAberturaController.text,
                                    style: TextStyle(
                                      color: kSecondaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Término dos pedidos',
                                style: TextStyle(
                                  color: kSecondaryColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: size.height * 0.018,
                                ),
                              ),
                              Divider(height: size.height * 0.006, color: Colors.transparent),
                              IconButton(
                                icon: const Icon(Icons.access_time),
                                onPressed: () async {
                                  final selectedTime = await showTimePicker(
                                    context: context,
                                    cancelText: "Cancelar",
                                    confirmText: "Confirmar",
                                    hourLabelText: "Horas",
                                    minuteLabelText: "Minutos",
                                    helpText: "Insira o horário:",
                                    initialTime: _getInitialTime(controller.horarioFechamentoController),
                                    initialEntryMode: TimePickerEntryMode.inputOnly,
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: const ColorScheme.light(
                                            primary: kPrimaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: kPrimaryColor,
                                          ),
                                        ),
                                        child: MediaQuery(
                                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                          child: child!,
                                        ),
                                      );
                                    },
                                  );

                                  if (selectedTime != null) {
                                    final formattedTime = _formatTimeOfDayTo24Hour(selectedTime);
                                    final aberturaTime = controller.horarioAberturaController.text;

                                    if (_isClosingTimeInvalid(aberturaTime, formattedTime)) {
                                      _showSnackbar(context, "O horário de fechamento deve ser maior que o de abertura.");
                                      return;
                                    }

                                    setState(() {
                                      controller.horarioFechamentoController.text = formattedTime;
                                    });
                                  }
                                },
                              ),
                              if (controller.horarioFechamentoController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    controller.horarioFechamentoController.text,
                                    style: TextStyle(
                                      color: kSecondaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: size.height * 0.018,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      height: size.height * 0.018,
                      color: Colors.transparent,
                    ),
                    Text(
                      'Formas de Pagamento',
                      style: kTitle1.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: size.height * 0.018,
                        color: kSecondaryColor,
                      ),
                    ),
                    SizedBox(
                      width: size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: ListTileTheme(
                              horizontalTitleGap: 0,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                activeColor: kPrimaryColor,
                                value: controller.isSelected[0],
                                title: Text(
                                  controller.checkItems[0],
                                  style:
                                      TextStyle(fontSize: size.height * 0.016),
                                ),
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  controller.onItemTapped(0);
                                  print("valor do isSelected: ${controller.isSelected}");
                                }
                              ),
                            ),
                          ),
                          Flexible(
                            child: ListTileTheme(
                              horizontalTitleGap: 0,
                              child: CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                activeColor: kPrimaryColor,
                                value: controller.isSelected[1],
                                title: Text(
                                  controller.checkItems[1],
                                  style:
                                      TextStyle(fontSize: size.height * 0.016),
                                ),
                                checkboxShape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onChanged: (value) {
                                  controller.onItemTapped(1);
                                  controller.setPixBool(!controller.pixBool);
                                  print("valor do pix: ${controller.pixBool}");
                                  print("valor do isSelected: ${controller.isSelected}");
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: controller.pixBool,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chave Pix',
                            style: TextStyle(
                              fontSize: size.height * 0.018,
                              color: kSecondaryColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          IntrinsicWidth(
                            stepWidth: size.width,
                            child: Card(
                              margin: EdgeInsets.zero,
                              elevation: 0,
                              child: ClipPath(
                                child: Container(
                                  alignment: Alignment.center,
                                  child: CustomTextFormField(
                                    autoValidate:
                                        AutovalidateMode.onUserInteraction,
                                    enabled: controller.pixBool,
                                    erroStyle: const TextStyle(fontSize: 12),
                                    validatorError: (value) {
                                      if (controller.pixBool == true) {
                                        if (value.isEmpty) {
                                          return 'Obrigatório';
                                        }
                                      }
                                    },
                                    hintText: "Chave Pix",
                                    controller: controller.pixController,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const VerticalSpacerBox(size: SpacerSize.small),
                        ],
                      ),
                    ),
                    // Text(
                    //   'Realizará entregas?',
                    //   style: TextStyle(
                    //     fontSize: size.height * 0.018,
                    //     color: kSecondaryColor,
                    //     fontWeight: FontWeight.w700,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: size.height * 0.08,
                    //   child: Column(
                    //     mainAxisAlignment:
                    //         MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Flexible(
                    //         child: ListTileTheme(
                    //           horizontalTitleGap: 0,
                    //           child: CheckboxListTile(
                    //             contentPadding:
                    //                 EdgeInsets.zero,
                    //             activeColor: kPrimaryColor,
                    //             value:
                    //                 controller.delivery[0],
                    //             title: Text(
                    //               'Sim',
                    //               style: TextStyle(
                    //                   fontSize:
                    //                       size.height *
                    //                           0.018),
                    //             ),
                    //             checkboxShape:
                    //                 const CircleBorder(),
                    //             controlAffinity:
                    //                 ListTileControlAffinity
                    //                     .leading,
                    //             onChanged: (value) {
                    //               controller
                    //                   .onDeliveryTapped(0);
                    //             },
                    //           ),
                    //         ),
                    //       ),
                    //       Flexible(
                    //         child: ListTileTheme(
                    //           horizontalTitleGap: 0,
                    //           child: CheckboxListTile(
                    //             contentPadding:
                    //                 EdgeInsets.zero,
                    //             activeColor: kPrimaryColor,
                    //             value:
                    //                 controller.delivery[1],
                    //             title: Text(
                    //               'Não',
                    //               style: TextStyle(
                    //                   fontSize:
                    //                       size.height *
                    //                           0.018),
                    //             ),
                    //             checkboxShape:
                    //                 const CircleBorder(),
                    //             controlAffinity:
                    //                 ListTileControlAffinity
                    //                     .leading,
                    //             onChanged: (value) =>
                    //                 controller
                    //                     .onDeliveryTapped(
                    //                         1),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Visibility(
                    //   visible: controller.delivery[0],
                    //   child: Column(
                    //     crossAxisAlignment:
                    //         CrossAxisAlignment.start,
                    //     children: [
                    //       Divider(
                    //         height: size.height * 0.025,
                    //         color: Colors.transparent,
                    //       ),
                    //       Text(
                    //         'Valor mínimo para frete',
                    //         style: kTitle1.copyWith(
                    //           fontWeight: FontWeight.w700,
                    //           fontSize: size.height * 0.018,
                    //           color: kSecondaryColor,
                    //         ),
                    //       ),
                    //       SizedBox(
                    //         width: size.width,
                    //         child: Card(
                    //           margin: EdgeInsets.zero,
                    //           elevation: 0,
                    //           child: ClipPath(
                    //             child: Container(
                    //               alignment:
                    //                   Alignment.center,
                    //               child:
                    //                   CustomTextFormFieldCurrency(
                    //                 autoValidate:
                    //                     AutovalidateMode
                    //                         .onUserInteraction,
                    //                 enabled: controller
                    //                     .delivery[0],
                    //                 erroStyle:
                    //                     const TextStyle(
                    //                         fontSize: 12),
                    //                 validatorError:
                    //                     (value) {
                    //                   if (controller
                    //                               .delivery[
                    //                           0] ==
                    //                       true) {
                    //                     if (value.isEmpty) {
                    //                       return 'Obrigatório';
                    //                     }
                    //                   }
                    //                 },
                    //                 hintText:
                    //                     "R\$ $freteCorreto",
                    //                 currencyFormatter: <TextInputFormatter>[
                    //                   CurrencyTextInputFormatter
                    //                       .currency(
                    //                     locale: 'pt_BR',
                    //                     symbol: 'R\$',
                    //                     decimalDigits: 2,
                    //                   ),
                    //                   LengthLimitingTextInputFormatter(
                    //                       8),
                    //                 ],
                    //                 keyboardType:
                    //                     TextInputType
                    //                         .number,
                    //                 controller: controller
                    //                     .quantiaMinController,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    const VerticalSpacerBox(size: SpacerSize.large),
                    SizedBox(
                      width: size.width,
                      height: size.height * 0.06,
                      child: PrimaryButton(
                        text: 'Salvar',
                        onPressed: () {
                          ("Validando formulário...");
                          if (controller.formKey.currentState?.validate() ??
                              false) {
                            ("Formulário validado com sucesso.");

                            if (controller.verifyFields()) {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    DefaultAlertDialogOneButton(
                                  title: 'Êxito',
                                  body:
                                      'Suas informações foram alteradas com sucesso',
                                  confirmText: 'Ok',
                                  onConfirm: () {
                                    Get.back();
                                    controller.editBanca(
                                        context, widget.bancaModel!);
                                  },
                                  buttonColor: kAlertColor,
                                ),
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    DefaultAlertDialogOneButton(
                                  title: 'Erro',
                                  body: controller.textoErro,
                                  confirmText: 'Voltar',
                                  onConfirm: () => Get.back(),
                                  buttonColor: kAlertColor,
                                ),
                              );
                            }
                          } else {
                            ("Formulário não validado.");
                          }
                        },
                      ),
                    ),

                    Divider(
                        height: size.height * 0.015, color: Colors.transparent),
                    SizedBox(
                      width: size.width,
                      height: size.height * 0.06,
                      child: OutlinedButton(
                        onPressed: () => Get.off(() => const HomeScreen()),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                              color: Colors.orange, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: Text(
                          'Voltar',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: size.height * 0.024,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? _validateTimes(String startTime, String endTime) {
  List<int> start = _extractHoursAndMinutes(startTime);
  List<int> end = _extractHoursAndMinutes(endTime);
  if ((start[0] * 60 + start[1]) >= (end[0] * 60 + end[1])) {
    return 'O horário de início deve ser anterior ao horário de término.';
  }
  return null;
}

List<int> _extractHoursAndMinutes(String time) {
  final exp = RegExp(r"(\d{2})+:?(\d{2})+");
  Match? match = exp.firstMatch(time);

  if (match != null) {
    int hours = int.parse(match.group(1)!);
    int minutes = int.parse(match.group(2)!);
    return [hours, minutes];
  } else {
    // Se não houver correspondência, retorna uma lista com valores padrão
    return [0, 0];
  }
}

class _HourInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String newText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (newText.length > 4) {
      newText = newText.substring(0, 4);
    }

    if (newText.length >= 2) {
      int hours = int.parse(newText.substring(0, 2));
      hours = hours.clamp(0, 23);

      String formattedText = hours.toString().padLeft(2, '0');

      if (newText.length >= 3) {
        int minutes =
            int.tryParse(newText.substring(2, min(newText.length, 4))) ?? 0;

        if (newText.length > 3) {
          minutes = minutes.clamp(0, 59);
          formattedText += ':${minutes.toString().padLeft(2, '0')}';
        } else {
          formattedText += ':$minutes';
        }
      } else {
        formattedText += ':${newText.substring(2)}';
      }

      newText = formattedText;
    }

    if (newValue.text.length < oldValue.text.length) {
      newText = newText.substring(0, max(0, newText.length - 1));
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

bool _isClosingTimeInvalid(String abertura, String fechamento) {
  if (abertura.isEmpty || fechamento.isEmpty) return false;

  final aberturaParts = abertura.split(":").map(int.parse).toList();
  final fechamentoParts = fechamento.split(":").map(int.parse).toList();

  final aberturaMinutes = aberturaParts[0] * 60 + aberturaParts[1];
  final fechamentoMinutes = fechamentoParts[0] * 60 + fechamentoParts[1];

  return fechamentoMinutes <= aberturaMinutes;
}

void _showSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 2),
    ),
  );
}
