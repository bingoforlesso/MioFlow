part of 'chat_bloc.dart';

@freezed
class ChatEvent with _$ChatEvent {
  const factory ChatEvent.started() = _Started;
  const factory ChatEvent.messageSent(String message) = _MessageSent;
  const factory ChatEvent.voiceMessageSent(String audioPath) =
      _VoiceMessageSent;
  const factory ChatEvent.imageMessageSent(String imagePath) =
      _ImageMessageSent;
  const factory ChatEvent.productSelected(
          String productCode, Map<String, String> specifications) =
      _ProductSelected;
  const factory ChatEvent.helpRequested() = _HelpRequested;
}
