import 'package:family_tree/person/cubit/edit_person_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

class EditPersonForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<EditPersonCubit, EditPersonState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        final messenger = ScaffoldMessenger.of(context);
        if (state.status == FormzSubmissionStatus.failure) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Please fill the required fields.')),
            );
        } else if (state.status == FormzSubmissionStatus.success) {
          messenger
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Person saved.')),
            );
          Navigator.of(context).pop(true);
        }
      },
      child: Container(
        margin: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.grey.withAlpha(40),
                child: Row(
                  children: [
                    const Flexible(
                      flex: 2,
                      fit: FlexFit.tight,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Flexible(
                      flex: 6,
                      fit: FlexFit.tight,
                      child: Container(
                        color: Colors.grey.withAlpha(40),
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FirstNamesInput(),
                            _LastNamesInput(),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                color: Colors.grey.withAlpha(40),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Birthdate'),
                    Text(' ->'),
                    Text('Deathdate'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                color: Colors.grey.withAlpha(40),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Add Mother'),
                    Text('Add Father'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                color: Colors.grey.withAlpha(40),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Add Spouses'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                color: Colors.grey.withAlpha(40),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Add Children'),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 15),
                color: Colors.grey.withAlpha(40),
                child: const _DescriptionInput(),
              ),
              const SizedBox(height: 24),
              _SaveButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FirstNamesInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonCubit, EditPersonState>(
      buildWhen: (prev, current) => prev.firstNames != current.firstNames,
      builder: (context, state) {
        return TextField(
          key: const Key('editPersonForm_firstNameInput_textField'),
          onChanged: (firstNames) =>
              context.read<EditPersonCubit>().firstNamesChanged(firstNames),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'First Names',
            errorText:
                state.firstNames.isNotValid ? 'Invalid First Names' : null,
          ),
        );
      },
    );
  }
}

class _LastNamesInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonCubit, EditPersonState>(
      buildWhen: (prev, current) => prev.lastNames != current.lastNames,
      builder: (context, state) {
        return TextField(
          key: const Key('editPersonForm_lastNameInput_textField'),
          onChanged: (lastNames) =>
              context.read<EditPersonCubit>().lastNamesChanged(lastNames),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintText: 'Last Names',
            errorText:
                state.lastNames.isNotValid ? 'Invalid Last Names' : null,
          ),
        );
      },
    );
  }
}

class _DescriptionInput extends StatelessWidget {
  const _DescriptionInput();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonCubit, EditPersonState>(
      buildWhen: (prev, current) => prev.description != current.description,
      builder: (context, state) {
        return TextField(
          key: const Key('editPersonForm_descriptionInput_textField'),
          onChanged: context.read<EditPersonCubit>().descriptionChanged,
          keyboardType: TextInputType.multiline,
          maxLines: 8,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(12),
            border: InputBorder.none,
            hintText: 'Description',
          ),
        );
      },
    );
  }
}

class _SaveButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditPersonCubit, EditPersonState>(
      buildWhen: (prev, current) =>
          prev.status != current.status ||
          prev.firstNames != current.firstNames ||
          prev.lastNames != current.lastNames,
      builder: (context, state) {
        final isValid = Formz.validate([state.firstNames, state.lastNames]);
        if (state.status == FormzSubmissionStatus.inProgress) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: CircularProgressIndicator(),
          );
        }
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.save_outlined),
            label: const Text('SAVE'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: isValid
                ? () => context.read<EditPersonCubit>().savePerson()
                : null,
          ),
        );
      },
    );
  }
}
