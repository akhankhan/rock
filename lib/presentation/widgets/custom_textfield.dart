import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:country_picker/country_picker.dart';

const Color kBluePrimary = Color(0xFF2196F3);
const Color kBlack20 = Color(0xFF333333);
const Color kGreyf3 = Color(0xFFF3F3F3);
const Color kGrey = Color(0xFFAAAAAA);

const kInterMedium = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w500,
);

const kInterRegular = TextStyle(
  fontFamily: 'Inter',
  fontWeight: FontWeight.w400,
);

class CustomTextField extends StatefulWidget {
  final String labelText;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType keyboardType;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<String>? phoneCodes;
  final String? selectedPhoneCode;
  final ValueChanged<String>? onPhoneCodeChanged;
  final int? maxLines;
  final List<String>? dropdownItems;
  final String? selectedDropdownItem;
  final ValueChanged<String?>? onDropdownChanged;
  final bool isPhoneNumber;
  final bool isDropDown;
  final bool isPrefixSVG;
  final SvgPicture? prefixSvgPic;
  final bool isExpandedVerticalContainer;
  final ValueChanged<String>? onChange;
  final bool isBorderShow;
  final Color? color;
  final bool isLabelTextShow;
  final bool isCountryShow;
  final ValueChanged<Country>? onCountryChanged;
  final bool? isEnabled;
  final bool isPhoneWithCountryPicker;

  const CustomTextField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.suffixIcon,
    required this.hint,
    this.prefixIcon,
    this.phoneCodes,
    this.selectedPhoneCode,
    this.onPhoneCodeChanged,
    this.maxLines,
    this.dropdownItems,
    this.selectedDropdownItem,
    this.onDropdownChanged,
    this.isPhoneNumber = false,
    this.isDropDown = false,
    this.isPrefixSVG = false,
    this.prefixSvgPic,
    this.isExpandedVerticalContainer = false,
    this.onChange,
    this.isBorderShow = true,
    this.color,
    this.isLabelTextShow = true,
    this.isCountryShow = false,
    this.onCountryChanged,
    this.isEnabled,
    this.isPhoneWithCountryPicker = false,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _hasError = false;
  late FocusNode _focusNode;
  String? _errorText;
  bool _obscureText = false;
  Country? _selectedCountry;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
    widget.controller.addListener(_validateInput);
    _obscureText = widget.obscureText;
    if (widget.isPhoneWithCountryPicker) {
      _selectedCountry = Country.worldWide;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    widget.controller.removeListener(_validateInput);
    super.dispose();
  }

  void _handleFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _validateInput() {
    if (widget.validator != null) {
      final error = widget.validator!(widget.controller.text);
      setState(() {
        _hasError = error != null;
        _errorText = error;
      });
    }
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isCountryShow)
          SizedBox(
            height: 52.h,
            child: TextFormField(
              controller: widget.controller,
              readOnly: true,
              decoration: _getInputDecoration().copyWith(
                hintText: _selectedCountry?.name ?? 'Select a country',
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ),
              onTap: () {
                showCountryPicker(
                  context: context,
                  showPhoneCode: false,
                  onSelect: (Country country) {
                    setState(() {
                      _selectedCountry = country;
                      widget.controller.text =
                          '${country.flagEmoji} ${country.name}';
                    });
                    if (widget.onCountryChanged != null) {
                      widget.onCountryChanged!(country);
                    }
                  },
                );
              },
            ),
          )
        else if (widget.isDropDown)
          SizedBox(
            height: 52.h,
            child: DropdownButtonFormField<String>(
              value: widget.selectedDropdownItem,
              items: widget.dropdownItems!.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: widget.onDropdownChanged,
              decoration: _getInputDecoration().copyWith(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
                hintText: widget.hint,
                hintStyle: kInterMedium.copyWith(fontSize: 14.sp),
                alignLabelWithHint: true,
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
              style: TextStyle(fontSize: 16.sp, color: kBlack20),
              icon: const Icon(Icons.arrow_drop_down, color: kBlack20),
              dropdownColor: kGreyf3,
              isExpanded: true,
            ),
          )
        else if (widget.isPhoneWithCountryPicker)
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.phone,
            style: TextStyle(fontSize: 16.sp),
            decoration: _getInputDecoration().copyWith(
              prefixIcon: _buildCountryPickerPrefix(),
            ),
            onChanged: widget.onChange ?? (value) {},
          )
        else
          Container(
            padding: widget.isExpandedVerticalContainer
                ? EdgeInsets.symmetric(
                    vertical: widget.maxLines == null ? 8.h : 0,
                    horizontal: widget.maxLines == null ? 10.h : 0,
                  )
                : null,
            decoration: BoxDecoration(
                color: widget.color, borderRadius: BorderRadius.circular(8)),
            height: widget.isExpandedVerticalContainer
                ? null
                : widget.maxLines != null
                    ? null
                    : 52.h,
            child: TextFormField(
              controller: widget.controller,
              focusNode: _focusNode,
              obscureText: _obscureText,
              enabled: widget.isEnabled ?? true,
              keyboardType: widget.keyboardType,
              maxLines: _obscureText
                  ? 1
                  : (widget.isExpandedVerticalContainer
                      ? null
                      : widget.maxLines ?? 1),
              validator: (value) {
                final error = widget.validator?.call(value);
                setState(() {
                  _hasError = error != null;
                  _errorText = error;
                });
                return null;
              },
              style: TextStyle(
                fontSize: 16.sp,
              ),
              decoration: _getInputDecoration(),
              onChanged: widget.onChange ?? (va) {},
            ),
          ),
        if (_hasError) ...[
          10.verticalSpace,
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 18,
                color: Colors.red,
              ),
              5.horizontalSpace,
              Expanded(
                child: Text(
                  _errorText ?? '',
                  style: kInterRegular.copyWith(
                    fontSize: 11.sp,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildCountryPickerPrefix() {
    return InkWell(
      onTap: () {
        showCountryPicker(
          context: context,
          showPhoneCode: true,
          onSelect: (Country country) {
            setState(() {
              _selectedCountry = country;
            });
            if (widget.onCountryChanged != null) {
              widget.onCountryChanged!(country);
            }
          },
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          15.horizontalSpace,
          Text(
            _selectedCountry?.flagEmoji ?? '🌎',
            style: TextStyle(fontSize: 20.sp),
          ),
          5.horizontalSpace,
          Text(
            '+${_selectedCountry?.phoneCode ?? ''}',
            style: TextStyle(fontSize: 14.sp),
          ),
          10.horizontalSpace,
          Container(
            width: 1,
            height: 20.h,
            color: Colors.grey,
          ),
          10.horizontalSpace,
        ],
      ),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      alignLabelWithHint: true,
      isDense: true,
      hintText: widget.hint,
      hintStyle: kInterMedium.copyWith(fontSize: 14.sp),
      labelText: widget.isLabelTextShow ? widget.labelText : null,
      labelStyle: kInterMedium.copyWith(
        fontSize: 13.sp,
        color: _isFocused ? kBluePrimary : kBlack20,
      ),
      border: widget.isBorderShow
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            )
          : InputBorder.none,
      enabledBorder: widget.isBorderShow
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                width: 1.5,
                color: Colors.grey,
              ),
            )
          : InputBorder.none,
      focusedBorder: widget.isBorderShow
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                width: 1.5,
                color: kBluePrimary,
              ),
            )
          : InputBorder.none,
      errorBorder: widget.isBorderShow
          ? OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: const BorderSide(
                width: 1.5,
                color: Colors.red,
              ),
            )
          : InputBorder.none,
      prefixIcon: widget.isPhoneNumber
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: PhoneCodeDropdown(
                    phoneCodes: widget.phoneCodes!,
                    selectedCode: widget.selectedPhoneCode!,
                    onCodeChanged: widget.onPhoneCodeChanged!,
                  ),
                ),
                Flexible(
                  child: Container(
                    width: 1.3,
                    color: kGrey,
                    height: 35.h,
                  ),
                ),
                5.horizontalSpace,
              ],
            )
          : widget.isPrefixSVG
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    15.horizontalSpace,
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: widget.prefixSvgPic,
                    ),
                    5.horizontalSpace,
                    Flexible(
                      child: Container(
                        width: 1.3,
                        color: kGrey,
                        height: 35.h,
                      ),
                    ),
                    5.horizontalSpace,
                  ],
                )
              : widget.prefixIcon,
      suffixIcon: widget.isCountryShow
          ? null
          : (widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: _toggleObscureText,
                )
              : widget.suffixIcon),
    );
  }
}

class PhoneCodeDropdown extends StatelessWidget {
  final List<String> phoneCodes;
  final String selectedCode;
  final ValueChanged<String> onCodeChanged;

  const PhoneCodeDropdown({
    super.key,
    required this.phoneCodes,
    required this.selectedCode,
    required this.onCodeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedCode,
      icon: const Icon(Icons.arrow_drop_down),
      iconSize: 24,
      elevation: 16,
      style: const TextStyle(color: Colors.black),
      underline: Container(
        height: 2,
        color: Colors.transparent,
      ),
      onChanged: (String? newValue) {
        if (newValue != null) {
          onCodeChanged(newValue);
        }
      },
      items: phoneCodes.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
