import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:thunderapp/components/forms/custom_text_form_field.dart';
import 'package:thunderapp/shared/constants/style_constants.dart';
import '../../../shared/core/models/products_model.dart';
import '../edit_products_controller.dart';
import 'dropdown_edit_product.dart';

// ignore: must_be_immutable
class SaleInfos extends StatefulWidget {
  final EditProductsController controller;
  ProductsModel? productsModel;

  SaleInfos(this.controller, this.productsModel, {Key? key}) : super(key: key);

  @override
  State<SaleInfos> createState() => _SaleInfosState();
}

class _SaleInfosState extends State<SaleInfos> {
  double profit = 0.0;

  @override
  void initState() {
    widget.controller.titleController.text = widget.productsModel?.titulo ?? '';
    widget.controller.descriptionController.text =
        widget.productsModel?.descricao ?? '';
    // Formata o preço no formato "R$" e atribui ao controller
    double preco = double.tryParse(
            (widget.productsModel?.preco ?? 0.00).toStringAsFixed(2)) ??
        0.00;
    String formattedPrice =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
            .format(preco);
    // Atribui o valor formatado ao controlador de texto
    widget.controller.saleController.text = formattedPrice;
    widget.controller.stockController.text =
        widget.productsModel?.estoque?.toString() ?? '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final double? preco = widget.productsModel!.preco;
    final String? precoCorreto =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(preco);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nome do produto',
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: size.height * 0.018,
                  fontWeight: FontWeight.w700),
            ),
            Divider(
              height: size.height * 0.005,
              color: Colors.transparent,
            ),
            SizedBox(
              width: size.width,
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                child: ClipPath(
                  child: CustomTextFormField(
                    hintText: widget.productsModel!.titulo,
                    erroStyle: const TextStyle(fontSize: 12),
                    validatorError: (value) {
                      if (value.isEmpty) {
                        return 'Obrigatório';
                      }
                    },
                    onChanged: (value) {
                      setState(() {
                        widget.controller.setTitle();
                      });
                    },
                    controller: widget.controller.titleController,
                  ),
                ),
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: size.height * 0.03,
              color: Colors.transparent,
            ),
            Text(
              'Descrição',
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: size.height * 0.018,
                  fontWeight: FontWeight.w700),
            ),
            Divider(
              height: size.height * 0.005,
              color: Colors.transparent,
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
                      hintText: widget.productsModel!.descricao,
                      erroStyle: const TextStyle(fontSize: 12),
                      validatorError: (value) {
                        if (value.isEmpty) {
                          return 'Obrigatório';
                        }
                      },
                      onChanged: (value) {
                        setState(() {
                          widget.controller.setDescription();
                        });
                      },
                      controller: widget.controller.descriptionController,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(
              height: size.height * 0.03,
              color: Colors.transparent,
            ),
            Text(
              'Imagem do Produto',
              style: TextStyle(
                  color: kSecondaryColor,
                  fontSize: size.height * 0.018,
                  fontWeight: FontWeight.w700),
            ),
            Divider(
              height: size.height * 0.005,
              color: Colors.transparent,
            ),
            DropDownEditProduct(widget.controller, widget.productsModel!),
            Divider(
              height: size.height * 0.03,
              color: Colors.transparent,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: AlignmentDirectional.topStart,
              child: Text(
                'Preço',
                style: TextStyle(
                    color: kSecondaryColor,
                    fontSize: size.height * 0.018,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Divider(
              height: size.height * 0.005,
              color: Colors.transparent,
            ),
            SizedBox(
              width: size.width,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                child: ClipPath(
                  child: Container(
                    alignment: Alignment.center,
                    child: CustomTextFormFieldCurrency(
                      keyboardType: TextInputType.number,
                      erroStyle: const TextStyle(fontSize: 12),
                      validatorError: (value) {
                        if (value.isEmpty) {
                          return 'Obrigatório';
                        }
                      },
                      hintText: "R\$ $precoCorreto",
                      onChanged: (value) {
                        setState(() {
                          widget.controller.setSalePrice();
                        });
                      },
                      currencyFormatter: <TextInputFormatter>[
                        CurrencyTextInputFormatter.currency(
                          locale: 'pt_BR',
                          symbol: 'R\$',
                          decimalDigits: 2,
                        ),
                        LengthLimitingTextInputFormatter(9),
                      ],
                      controller: widget.controller.saleController,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
