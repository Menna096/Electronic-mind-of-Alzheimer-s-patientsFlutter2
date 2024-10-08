import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:vv/Notes/voice/core/utils/app_bottom_sheet.dart';
import 'package:vv/Notes/voice/core/utils/constants/app_colors.dart';
import 'package:vv/Notes/voice/core/utils/constants/app_styles.dart';
import 'package:vv/Notes/voice/home/manager/audio_recorder_manager/audio_recorder_file_helper.dart';
import 'package:vv/Notes/voice/home/manager/voice_notes_cubit/voice_notes_cubit.dart';
import 'package:vv/Notes/voice/home/model/voice_note_model.dart';
import 'package:vv/Notes/voice/home/widgets/audio_recorder_view/audio_recorder_view.dart';
import 'package:vv/Notes/voice/home/widgets/voice_note_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, Key? key2});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VoiceNotesCubit(AudioRecorderFileHelper()),
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  final PagingController<int, VoiceNoteModel> pagingController =
      PagingController(firstPageKey: 1, invisibleItemsThreshold: 6);

  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      context.read<VoiceNotesCubit>().getAllVoiceNotes(pageKey);
    });
    super.initState();
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  void onDataFetched(VoiceNotesFetched state) {
    final data = state.voiceNotes;

    final isLastPage =
        data.isEmpty || data.length < context.read<VoiceNotesCubit>().fetchLimit;
    if (isLastPage) {
      pagingController.appendLastPage(data);
    } else {
      final nextPageKey = (pagingController.nextPageKey ?? 0) + 1;
      pagingController.appendPage(data, nextPageKey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff3B5998),
        body: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xffFFFFFF), Color(0xff3B5998)],
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 16,
                    ),

                    Padding(
                     padding: const EdgeInsets.only(top: 30, left: 28, right: 28),
                      child: Text(
                        "Voice Notes".tr(),
                        style: AppTextStyles.bold(
                          fontSize: 34,
                          color: const Color.fromARGB(255, 124, 147, 198),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    Expanded(
                      child: BlocListener<VoiceNotesCubit, VoiceNotesState>(
                        listener: (context, state) {
                          if (state is VoiceNotesError) {
                            pagingController.error = state.message;
                          } else if (state is VoiceNotesFetched) {
                            onDataFetched(state);
                          } else if (state is VoiceNoteDeleted) {
                            final List<VoiceNoteModel> voiceNotes =
                                List.from(pagingController.value.itemList ?? []);
                            voiceNotes.remove(state.voiceNoteModel);
                            pagingController.itemList = voiceNotes;
                          } else if (state is VoiceNoteAdded) {
                            final List<VoiceNoteModel> newItems =
                                List.from(pagingController.itemList ?? []);
                            newItems.insert(0, state.voiceNoteModel);
                            pagingController.itemList = newItems;
                          }
                        },
                        child: PagedListView<int, VoiceNoteModel>(
                          pagingController: pagingController,
                          padding: const EdgeInsets.only(
                              right: 24, left: 24, bottom: 80),
                          builderDelegate: PagedChildBuilderDelegate(
                            noItemsFoundIndicatorBuilder: (context) {
                              return Column(children: [
                                const SizedBox(
                                  height: 100,
                                ),
                                Image.asset(
                                  "images/noteees.jpg",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  "No Voice Notes Yet!".tr(),
                                  style: AppTextStyles.medium(
                                      color: const Color.fromARGB(255, 227, 226, 226),
                                      fontSize: 21),
                                ),
                              ]);
                            },
                            firstPageErrorIndicatorBuilder: (context) {
                              return Center(
                                child: Column(
                                  children: [
                                    Text(pagingController.error.toString()),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    GestureDetector(
                                        onTap: () {
                                          pagingController.retryLastFailedRequest();
                                        },
                                        child: Text(
                                          "Retry".tr(),
                                          style: AppTextStyles.medium(),
                                        ))
                                  ],
                                ),
                              );
                            },
                            firstPageProgressIndicatorBuilder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            newPageProgressIndicatorBuilder: (context) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            },
                            noMoreItemsIndicatorBuilder: (context) {
                              return const SizedBox.shrink();
                            },
                            itemBuilder: (context, item, index) {
                              return VoiceNoteCard(voiceNoteInfo: item);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Positioned(
                bottom: 10,
                child: _AddRecordButton()
            )
          ],
        )
    );
  }
}

class _AddRecordButton extends StatelessWidget {
  const _AddRecordButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(100),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        splashColor: Colors.white12,
        onTap: () async {
          final VoiceNoteModel? newVoiceNote = await showAppBottomSheet(
              context,
              builder: (context) {
                return const AudioRecorderView();
              }
          );

          if (newVoiceNote != null && context.mounted) {
            context.read<VoiceNotesCubit>().addToVoiceNotes(newVoiceNote);
          }
        },
        child: const SizedBox(
          width: 75,
          height: 75,
          child: Icon(
            FeatherIcons.plus,
            color: AppColors.background,
            size: 28,
          ),
        ),
      ),
    );
  }
}
